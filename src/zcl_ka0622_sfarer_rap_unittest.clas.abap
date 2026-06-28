"! @testing ZBP_I_SFARER
CLASS zcl_ka0622_sfarer_rap_unittest DEFINITION
  PUBLIC
  FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS test_buy FOR TESTING.
    METHODS test_sell FOR TESTING.
    METHODS test_exchange FOR TESTING.

ENDCLASS.



CLASS zcl_ka0622_sfarer_rap_unittest IMPLEMENTATION.


  METHOD test_buy.

    DATA lv_before TYPE zka0622_t_sfarer-credits.
    DATA lv_after  TYPE zka0622_t_sfarer-credits.

    "-----------------------------------------
    " BEFORE
    "-----------------------------------------
    SELECT SINGLE credits
      FROM zka0622_t_sfarer
      WHERE spacefarer_id = '0000000001'
      INTO @lv_before.

    "-----------------------------------------
    " RAP ACTION CALL
    "-----------------------------------------
    MODIFY ENTITIES OF zka0622_vi_sfarer
      ENTITY zka0622_vi_sfarer
      EXECUTE buy
      FROM VALUE #(
        (
          spacefarer_id = '0000000001'
          %param = VALUE #(
            spacefarer_id = '0000000001'
            stardust_id   = '0000001002'
          )
        )
      )
      FAILED DATA(failed)
      REPORTED DATA(reported).

    COMMIT WORK AND WAIT.

    "-----------------------------------------
    " AFTER
    "-----------------------------------------
    SELECT SINGLE credits
      FROM zka0622_t_sfarer
      WHERE spacefarer_id = '0000000001'
      INTO @lv_after.

    cl_abap_unit_assert=>assert_true(
      xsdbool( lv_before <> lv_after ) ).

  ENDMETHOD.



  METHOD test_sell.

    DATA lv_before TYPE zka0622_t_sfarer-credits.
    DATA lv_after  TYPE zka0622_t_sfarer-credits.

    SELECT SINGLE credits
      FROM zka0622_t_sfarer
      WHERE spacefarer_id = '0000000001'
      INTO @lv_before.

    MODIFY ENTITIES OF zka0622_vi_sfarer
      ENTITY zka0622_vi_sfarer
      EXECUTE sell
      FROM VALUE #(
        (
          spacefarer_id = '0000000001'
          %param = VALUE #(
            spacefarer_id = '0000000001'
            stardust_id   = '0000001001'
          )
        )
      )
      FAILED DATA(failed)
      REPORTED DATA(reported).

    COMMIT ENTITIES.

    SELECT SINGLE credits
      FROM zka0622_t_sfarer
      WHERE spacefarer_id = '0000000001'
      INTO @lv_after.

    cl_abap_unit_assert=>assert_true(
      xsdbool( lv_before <> lv_after ) ).

  ENDMETHOD.



  METHOD test_exchange.

    DATA lv_before_1 TYPE zka0622_t_coll-spacefarer_id.
    DATA lv_before_2 TYPE zka0622_t_coll-spacefarer_id.

    DATA lv_after_1 TYPE zka0622_t_coll-spacefarer_id.
    DATA lv_after_2 TYPE zka0622_t_coll-spacefarer_id.

    "-----------------------------------------
    " BEFORE
    "-----------------------------------------
    SELECT SINGLE spacefarer_id
      FROM zka0622_t_coll
      WHERE collection_id = (
        SELECT collection_id
        FROM zka0622_t_sdust
        WHERE stardust_id = '0000001003'
      )
      INTO @lv_before_1.

    SELECT SINGLE spacefarer_id
      FROM zka0622_t_coll
      WHERE collection_id = (
        SELECT collection_id
        FROM zka0622_t_sdust
        WHERE stardust_id = '0000001002'
      )
      INTO @lv_before_2.

    "-----------------------------------------
    " RAP ACTION CALL
    "-----------------------------------------
    MODIFY ENTITIES OF zka0622_vi_sfarer
      ENTITY zka0622_vi_sfarer
      EXECUTE exchange
      FROM VALUE #(
        (
          %param = VALUE #(
            stardust_id_1 = '0000001003'
            stardust_id_2 = '0000001002'
          )
        )
      )
      FAILED DATA(failed)
      REPORTED DATA(reported).

    COMMIT ENTITIES.

    "-----------------------------------------
    " AFTER
    "-----------------------------------------
    SELECT SINGLE spacefarer_id
      FROM zka0622_t_coll
      WHERE collection_id = (
        SELECT collection_id
        FROM zka0622_t_sdust
        WHERE stardust_id = '0000001003'
      )
      INTO @lv_after_1.

    SELECT SINGLE spacefarer_id
      FROM zka0622_t_coll
      WHERE collection_id = (
        SELECT collection_id
        FROM zka0622_t_sdust
        WHERE stardust_id = '0000001002'
      )
      INTO @lv_after_2.

    cl_abap_unit_assert=>assert_true(
      xsdbool(
        lv_before_1 <> lv_after_1 OR
        lv_before_2 <> lv_after_2 ) ).

  ENDMETHOD.

ENDCLASS.
