CLASS zcl_ka0622_stardust_trading DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.


  PUBLIC SECTION.
    CLASS-METHODS calculate_price
      IMPORTING
        iv_price      TYPE zka0622_t_sdust-value
        iv_reputation TYPE zka0622_t_sfarer-reputation
        iv_mode       TYPE char4
      RETURNING
        VALUE(rv_price) TYPE zka0622_t_sdust-value.

    CLASS-METHODS buy
      IMPORTING
        iv_buyer_id    TYPE zka0622_t_sfarer-spacefarer_id
        iv_stardust_id TYPE zka0622_t_sdust-stardust_id.

    CLASS-METHODS sell
      IMPORTING
        iv_seller_id   TYPE zka0622_t_sfarer-spacefarer_id
        iv_stardust_id TYPE zka0622_t_sdust-stardust_id.

    CLASS-METHODS exchange
      IMPORTING
        iv_first_stardust  TYPE zka0622_t_sdust-stardust_id
        iv_second_stardust TYPE zka0622_t_sdust-stardust_id.

    CONSTANTS:
      gc_buy  TYPE c LENGTH 4 VALUE 'BUY',
      gc_sell TYPE c LENGTH 4 VALUE 'SELL'.

ENDCLASS.

CLASS zcl_ka0622_stardust_trading IMPLEMENTATION.

  METHOD calculate_price.

    rv_price = iv_price.

    DATA(lv_diff) = iv_reputation - 30.
    DATA(lv_percent) = abs( lv_diff ) DIV 5.

    IF lv_diff > 0.

      CASE iv_mode.
        WHEN gc_buy.
          rv_price = iv_price * ( 100 - lv_percent ) / 100.
        WHEN gc_sell.
          rv_price = iv_price * ( 100 + lv_percent ) / 100.
      ENDCASE.

    ELSEIF lv_diff < 0.

      CASE iv_mode.
        WHEN gc_buy.
          rv_price = iv_price * ( 100 + lv_percent ) / 100.
        WHEN gc_sell.
          rv_price = iv_price * ( 100 - lv_percent ) / 100.
      ENDCASE.

    ENDIF.

  ENDMETHOD.

  METHOD buy.

      DATA: ls_sdust    TYPE zka0622_t_sdust,
            ls_buyer    TYPE zka0622_t_sfarer,
            ls_coll     TYPE zka0622_t_coll,
            ls_seller   TYPE zka0622_t_sfarer,
            lv_price    TYPE zka0622_t_sdust-value,
            lv_owner_id TYPE zka0622_t_sfarer-spacefarer_id.

      "------------------------------------------------------------
      " Step 1: Read Stardust data
      "------------------------------------------------------------
      SELECT SINGLE *
        FROM zka0622_t_sdust
        WHERE stardust_id = @iv_stardust_id
        INTO @ls_sdust.

      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      "------------------------------------------------------------
      " Step 2: Read buyer data
      "------------------------------------------------------------
      SELECT SINGLE *
        FROM zka0622_t_sfarer
        WHERE spacefarer_id = @iv_buyer_id
        INTO @ls_buyer.

      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      "------------------------------------------------------------
      " Step 3: Determine current ownership
      "------------------------------------------------------------
      SELECT SINGLE *
        FROM zka0622_t_coll
        WHERE collection_id = @ls_sdust-collection_id
        INTO @ls_coll.

      lv_owner_id = ls_coll-spacefarer_id.

      "------------------------------------------------------------
      " Step 4: Calculate purchase price based on reputation
      "------------------------------------------------------------
      lv_price = calculate_price(
                    iv_price      = ls_sdust-value
                    iv_reputation = ls_buyer-reputation
                    iv_mode       = gc_buy ).

      "------------------------------------------------------------
      " Step 5: Check if buyer has enough credits
      "------------------------------------------------------------
      IF ls_buyer-credits < lv_price.
        RETURN.
      ENDIF.

      "------------------------------------------------------------
      " Step 6: Deduct credits from buyer
      "------------------------------------------------------------
      ls_buyer-credits = ls_buyer-credits - lv_price.

      UPDATE zka0622_t_sfarer
        SET credits = @ls_buyer-credits
        WHERE spacefarer_id = @ls_buyer-spacefarer_id.

      "------------------------------------------------------------
      " Step 7: Add credits to seller (if exists)
      "------------------------------------------------------------
      IF lv_owner_id IS NOT INITIAL AND lv_owner_id <> iv_buyer_id.

        SELECT SINGLE *
          FROM zka0622_t_sfarer
          WHERE spacefarer_id = @lv_owner_id
          INTO @ls_seller.

        IF sy-subrc = 0.

          ls_seller-credits = ls_seller-credits + lv_price.

          UPDATE zka0622_t_sfarer
            SET credits = @ls_seller-credits
            WHERE spacefarer_id = @ls_seller-spacefarer_id.

        ENDIF.

      ENDIF.

      "------------------------------------------------------------
      " Step 8: Transfer ownership to buyer
      "------------------------------------------------------------
      ls_coll-spacefarer_id = iv_buyer_id.

      UPDATE zka0622_t_coll
        SET spacefarer_id = @iv_buyer_id
        WHERE collection_id = @ls_coll-collection_id.

      "------------------------------------------------------------
      " Step 9: Commit transaction
      "------------------------------------------------------------
      COMMIT WORK.

  ENDMETHOD.

  METHOD sell.

      DATA: ls_sdust    TYPE zka0622_t_sdust,
            ls_seller   TYPE zka0622_t_sfarer,
            ls_coll     TYPE zka0622_t_coll,
            lv_price    TYPE zka0622_t_sdust-value,
            lv_owner_id TYPE zka0622_t_sfarer-spacefarer_id.

      "------------------------------------------------------------
      " Step 1: Read Stardust data
      "------------------------------------------------------------
      SELECT SINGLE *
        FROM zka0622_t_sdust
        WHERE stardust_id = @iv_stardust_id
        INTO @ls_sdust.

      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      "------------------------------------------------------------
      " Step 2: Determine current owner from collection
      "------------------------------------------------------------
      SELECT SINGLE *
        FROM zka0622_t_coll
        WHERE collection_id = @ls_sdust-collection_id
        INTO @ls_coll.

      lv_owner_id = ls_coll-spacefarer_id.

      IF lv_owner_id IS INITIAL.
        RETURN.
      ENDIF.

      "------------------------------------------------------------
      " Step 3: Read seller data
      "------------------------------------------------------------
      SELECT SINGLE *
        FROM zka0622_t_sfarer
        WHERE spacefarer_id = @iv_seller_id
        INTO @ls_seller.

      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      "------------------------------------------------------------
      " Step 4: Calculate selling price based on reputation
      "------------------------------------------------------------
      lv_price = calculate_price(
                    iv_price      = ls_sdust-value
                    iv_reputation = ls_seller-reputation
                    iv_mode       = gc_sell ).

      "------------------------------------------------------------
      " Step 5: Increase seller credits
      "------------------------------------------------------------
      ls_seller-credits = ls_seller-credits + lv_price.

      UPDATE zka0622_t_sfarer
        SET credits = @ls_seller-credits
        WHERE spacefarer_id = @ls_seller-spacefarer_id.

      "------------------------------------------------------------
      " Step 6: Remove ownership (item goes back to market)
      "------------------------------------------------------------
      CLEAR ls_coll-spacefarer_id.

      UPDATE zka0622_t_coll
        SET spacefarer_id = ''
        WHERE collection_id = @ls_coll-collection_id.

      "------------------------------------------------------------
      " Step 7: Commit transaction
      "------------------------------------------------------------
      COMMIT WORK.

  ENDMETHOD.

  METHOD exchange.

        DATA: ls_sdust_1 TYPE zka0622_t_sdust,
            ls_sdust_2 TYPE zka0622_t_sdust,
            ls_coll_1  TYPE zka0622_t_coll,
            ls_coll_2  TYPE zka0622_t_coll.

      "------------------------------------------------------------
      " Step 1: Read first Stardust
      "------------------------------------------------------------
      SELECT SINGLE *
        FROM zka0622_t_sdust
        WHERE stardust_id = @iv_first_stardust
        INTO @ls_sdust_1.

      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      "------------------------------------------------------------
      " Step 2: Read second Stardust
      "------------------------------------------------------------
      SELECT SINGLE *
        FROM zka0622_t_sdust
        WHERE stardust_id = @iv_second_stardust
        INTO @ls_sdust_2.

      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      "------------------------------------------------------------
      " Step 3: Read ownership of first Stardust
      "------------------------------------------------------------
      SELECT SINGLE *
        FROM zka0622_t_coll
        WHERE collection_id = @ls_sdust_1-collection_id
        INTO @ls_coll_1.

      "------------------------------------------------------------
      " Step 4: Read ownership of second Stardust
      "------------------------------------------------------------
      SELECT SINGLE *
        FROM zka0622_t_coll
        WHERE collection_id = @ls_sdust_2-collection_id
        INTO @ls_coll_2.

      "------------------------------------------------------------
      " Step 5: Swap owners between the two Stardusts
      "------------------------------------------------------------
      DATA(lv_temp_owner) = ls_coll_1-spacefarer_id.

      ls_coll_1-spacefarer_id = ls_coll_2-spacefarer_id.
      ls_coll_2-spacefarer_id = lv_temp_owner.

      "------------------------------------------------------------
      " Step 6: Update database - first Stardust ownership
      "------------------------------------------------------------
      UPDATE zka0622_t_coll
        SET spacefarer_id = @ls_coll_1-spacefarer_id
        WHERE collection_id = @ls_coll_1-collection_id.

      "------------------------------------------------------------
      " Step 7: Update database - second Stardust ownership
      "------------------------------------------------------------
      UPDATE zka0622_t_coll
        SET spacefarer_id = @ls_coll_2-spacefarer_id
        WHERE collection_id = @ls_coll_2-collection_id.

      "------------------------------------------------------------
      " Step 8: Commit transaction
      "------------------------------------------------------------
      COMMIT WORK.

  ENDMETHOD.

ENDCLASS.
