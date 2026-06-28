CLASS lhc_zka0622_vi_sfarer DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.

  PRIVATE SECTION.

    METHODS validate_reputation FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZKA0622_VI_SFARER~validate_reputation.

    METHODS get_instance_features
      FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZKA0622_VI_SFARER RESULT result.

    METHODS buy
      FOR MODIFY
      IMPORTING keys FOR ACTION ZKA0622_VI_SFARER~buy.

    METHODS sell
      FOR MODIFY
      IMPORTING keys FOR ACTION ZKA0622_VI_SFARER~sell.

    METHODS exchange
      FOR MODIFY
      IMPORTING keys FOR ACTION ZKA0622_VI_SFARER~exchange.

ENDCLASS.

CLASS lhc_zka0622_vi_sfarer IMPLEMENTATION.

METHOD validate_reputation.
*
*  READ ENTITIES OF ZKA0622_VI_SFARER
*      IN LOCAL MODE
*      ENTITY ZKA0622_VI_SFARER
*      ALL FIELDS
*      WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_data).
*
*  LOOP AT lt_data INTO DATA(ls_data).
*
*    IF ls_data-wormhole_skill + ls_data-reputation >= 99.
*
*      APPEND VALUE #(
*        %tky = ls_data-%tky
*      ) TO failed-zka0622_vi_sfarer.
*
*      APPEND VALUE #(
*        %tky = ls_data-%tky
*        %msg = new_message_with_text(
*          severity = if_abap_behv_message=>severity-error
*          text     = 'Navigation Skill + Reputation must be less than 99'
*        )
*      ) TO reported-zka0622_vi_sfarer.
*
*    ENDIF.
*
* ENDLOOP.

ENDMETHOD.

METHOD get_instance_features.

  result = VALUE #(
    FOR key IN keys
    (
      %tky = key-%tky
      %action-Edit     = if_abap_behv=>fc-o-enabled
    )
  ).

ENDMETHOD.

METHOD buy.

  DATA: lv_price TYPE zka0622_t_sdust-value.

  READ TABLE keys INTO DATA(ls_key) INDEX 1.

  DATA(lv_buyer_id)    = ls_key-%param-spacefarer_id.
  DATA(lv_stardust_id) = ls_key-%param-stardust_id.

  " Read buyer
  READ ENTITIES OF zka0622_vi_sfarer
    ENTITY zka0622_vi_sfarer
    ALL FIELDS
    WITH VALUE #( ( spacefarer_id = lv_buyer_id ) )
    RESULT DATA(lt_buyer).

  IF lt_buyer IS INITIAL.
    RETURN.
  ENDIF.

  DATA(ls_buyer) = lt_buyer[ 1 ].

  " Read stardust
  READ ENTITIES OF zka0622_vi_sdust
    ENTITY zka0622_vi_sdust
    ALL FIELDS
    WITH VALUE #( ( stardust_id = lv_stardust_id ) )
    RESULT DATA(lt_sdust).

  IF lt_sdust IS INITIAL.
    RETURN.
  ENDIF.

  DATA(ls_sdust) = lt_sdust[ 1 ].

  " Price calculation
  lv_price = zcl_ka0622_stardust_trading=>calculate_price(
    iv_price      = ls_sdust-value
    iv_reputation = ls_buyer-reputation
    iv_mode       = zcl_ka0622_stardust_trading=>gc_buy ).

  " Credit check
  IF ls_buyer-credits < lv_price.
    RETURN.
  ENDIF.

  ls_buyer-credits -= lv_price.

  " Update buyer
  MODIFY ENTITIES OF zka0622_vi_sfarer
    ENTITY zka0622_vi_sfarer
    UPDATE FIELDS ( credits )
    WITH VALUE #(
      (
        spacefarer_id = ls_buyer-spacefarer_id
        credits       = ls_buyer-credits
      )
    ).

  " Transfer ownership
  MODIFY ENTITIES OF zka0622_vi_sdust
    ENTITY zka0622_vi_sdust
    UPDATE FIELDS ( collection_id )
    WITH VALUE #(
      (
        stardust_id   = ls_sdust-stardust_id
        collection_id = lv_buyer_id
      )
    ).

ENDMETHOD.

METHOD sell.

  READ TABLE keys INTO DATA(ls_key) INDEX 1.

  DATA(lv_seller_id)   = ls_key-%param-spacefarer_id.
  DATA(lv_stardust_id) = ls_key-%param-stardust_id.

  " Read seller
  READ ENTITIES OF zka0622_vi_sfarer
    ENTITY zka0622_vi_sfarer
    ALL FIELDS
    WITH VALUE #( ( spacefarer_id = lv_seller_id ) )
    RESULT DATA(lt_seller).

  IF lt_seller IS INITIAL.
    RETURN.
  ENDIF.

  DATA(ls_seller) = lt_seller[ 1 ].

  " Read stardust
  READ ENTITIES OF zka0622_vi_sdust
    ENTITY zka0622_vi_sdust
    ALL FIELDS
    WITH VALUE #( ( stardust_id = lv_stardust_id ) )
    RESULT DATA(lt_sdust).

  IF lt_sdust IS INITIAL.
    RETURN.
  ENDIF.

  DATA(ls_sdust) = lt_sdust[ 1 ].

  " Price calculation
  DATA(lv_price) = zcl_ka0622_stardust_trading=>calculate_price(
    iv_price      = ls_sdust-value
    iv_reputation = ls_seller-reputation
    iv_mode       = zcl_ka0622_stardust_trading=>gc_sell ).

  " Credit increase
  ls_seller-credits += lv_price.

  MODIFY ENTITIES OF zka0622_vi_sfarer
    ENTITY zka0622_vi_sfarer
    UPDATE FIELDS ( credits )
    WITH VALUE #(
      (
        spacefarer_id = ls_seller-spacefarer_id
        credits       = ls_seller-credits
      )
    ).

  " Remove ownership
  MODIFY ENTITIES OF zka0622_vi_sdust
    ENTITY zka0622_vi_sdust
    UPDATE FIELDS ( collection_id )
    WITH VALUE #(
      (
        stardust_id   = ls_sdust-stardust_id
        collection_id = ''
      )
    ).

ENDMETHOD.

METHOD exchange.

  READ TABLE keys INTO DATA(ls_key) INDEX 1.

  DATA(lv_sdust1) = ls_key-%param-stardust_id_1.
  DATA(lv_sdust2) = ls_key-%param-stardust_id_2.

  READ ENTITIES OF zka0622_vi_sdust
    ENTITY zka0622_vi_sdust
    ALL FIELDS
    WITH VALUE #(
      ( stardust_id = lv_sdust1 )
      ( stardust_id = lv_sdust2 )
    )
    RESULT DATA(lt_sdust).

  IF lines( lt_sdust ) < 2.
    RETURN.
  ENDIF.

  DATA(ls1) = lt_sdust[ 1 ].
  DATA(ls2) = lt_sdust[ 2 ].

  DATA(lv_tmp) = ls1-collection_id.
  ls1-collection_id = ls2-collection_id.
  ls2-collection_id = lv_tmp.

  MODIFY ENTITIES OF zka0622_vi_sdust
    ENTITY zka0622_vi_sdust
    UPDATE FIELDS ( collection_id )
    WITH VALUE #(
      (
        stardust_id   = ls1-stardust_id
        collection_id = ls1-collection_id
      )
      (
        stardust_id   = ls2-stardust_id
        collection_id = ls2-collection_id
      )
    ).

ENDMETHOD.

ENDCLASS.
