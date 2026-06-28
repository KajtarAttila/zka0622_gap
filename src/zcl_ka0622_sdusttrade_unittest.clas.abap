"! @testing zcl_ka0622_stardust_trading
CLASS zcl_ka0622_sdusttrade_unittest DEFINITION
  PUBLIC
  FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS test_calculate_price_buy_high FOR TESTING.
    METHODS test_calculate_price_sell_low FOR TESTING.

    METHODS test_buy_real FOR TESTING.
    METHODS test_sell_real FOR TESTING.
    METHODS test_exchange_real FOR TESTING.

ENDCLASS.



CLASS zcl_ka0622_sdusttrade_unittest IMPLEMENTATION.

  METHOD test_calculate_price_buy_high.

    DATA(lv_price) = zcl_ka0622_stardust_trading=>calculate_price(
      iv_price      = 100
      iv_reputation = 50
      iv_mode       = zcl_ka0622_stardust_trading=>gc_buy ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_price
      exp = 96 ).

  ENDMETHOD.

  METHOD test_calculate_price_sell_low.

    DATA(lv_price) = zcl_ka0622_stardust_trading=>calculate_price(
      iv_price      = 100
      iv_reputation = 10
      iv_mode       = zcl_ka0622_stardust_trading=>gc_sell ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_price
      exp = 96 ).

  ENDMETHOD.

  METHOD test_buy_real.

    DATA lv_before TYPE zka0622_t_sfarer-credits.
    DATA lv_after  TYPE zka0622_t_sfarer-credits.

    SELECT SINGLE credits
      FROM zka0622_t_sfarer
      WHERE spacefarer_id = '0000000001'
      INTO @lv_before.

    zcl_ka0622_stardust_trading=>buy(
      iv_buyer_id    = '0000000001'
      iv_stardust_id = '0000001002' ).

    SELECT SINGLE credits
      FROM zka0622_t_sfarer
      WHERE spacefarer_id = '0000000001'
      INTO @lv_after.

    cl_abap_unit_assert=>assert_true(
      xsdbool( lv_after <> lv_before ) ).

  ENDMETHOD.

  METHOD test_sell_real.

    DATA lv_before TYPE zka0622_t_sfarer-credits.
    DATA lv_after  TYPE zka0622_t_sfarer-credits.

    SELECT SINGLE credits
      FROM zka0622_t_sfarer
      WHERE spacefarer_id = '0000000001'
      INTO @lv_before.

    zcl_ka0622_stardust_trading=>sell(
      iv_seller_id   = '0000000001'
      iv_stardust_id = '0000001001' ).

    SELECT SINGLE credits
      FROM zka0622_t_sfarer
      WHERE spacefarer_id = '0000000001'
      INTO @lv_after.

    cl_abap_unit_assert=>assert_true(
      xsdbool( lv_after <> lv_before ) ).

  ENDMETHOD.

  METHOD test_exchange_real.

    DATA lv_before_1 TYPE zka0622_t_coll-spacefarer_id.
    DATA lv_before_2 TYPE zka0622_t_coll-spacefarer_id.

    DATA lv_after_1 TYPE zka0622_t_coll-spacefarer_id.
    DATA lv_after_2 TYPE zka0622_t_coll-spacefarer_id.

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

    zcl_ka0622_stardust_trading=>exchange(
      iv_first_stardust  = '0000001003'
      iv_second_stardust = '0000001002' ).

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
      xsdbool( lv_before_1 <> lv_after_1 OR lv_before_2 <> lv_after_2 ) ).

  ENDMETHOD.

ENDCLASS.
