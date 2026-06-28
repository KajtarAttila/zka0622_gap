CLASS zka0622_testdata DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zka0622_testdata IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA: lt_sfarer TYPE TABLE OF zka0622_t_sfarer,
          lt_coll   TYPE TABLE OF zka0622_t_coll,
          lt_sdust  TYPE TABLE OF zka0622_t_sdust.

    "----------------------------------------------------
    " SPACEFARERS
    "----------------------------------------------------
    lt_sfarer = VALUE #(
      ( client = sy-mandt spacefarer_id = '0000000001'
        name = 'Nova Star'
        wormhole_skill = 85
        reputation = 40
        origin_planet = 'Andromeda'
        spacesuit_color = 'Silver'
        credits = 50000 )

      ( client = sy-mandt spacefarer_id = '0000000002'
        name = 'Zorak Vex'
        wormhole_skill = 70
        reputation = 25
        origin_planet = 'Mars Prime'
        spacesuit_color = 'Red'
        credits = 30000 )

      ( client = sy-mandt spacefarer_id = '0000000003'
        name = 'Lyra Zenith'
        wormhole_skill = 6
        reputation = 3
        origin_planet = 'Venus Core'
        spacesuit_color = 'Blue'
        credits = 45000 )
    ).

    MODIFY zka0622_t_sfarer FROM TABLE @lt_sfarer.

    "----------------------------------------------------
    " COLLECTIONS
    "----------------------------------------------------
    lt_coll = VALUE #(
      ( client = sy-mandt collection_id = '0000000101' spacefarer_id = '0000000001' )
      ( client = sy-mandt collection_id = '0000000102' spacefarer_id = '0000000002' )
      ( client = sy-mandt collection_id = '0000000103' spacefarer_id = '0000000003' )
    ).

    MODIFY zka0622_t_coll FROM TABLE @lt_coll.

    "----------------------------------------------------
    " STARDUSTS
    "----------------------------------------------------
    lt_sdust = VALUE #(
      ( client = sy-mandt stardust_id = '0000001001'
        collection_id = '0000000101'
        color = 'Blue'
        weight = '10.50'
        state_of_matter = 'Solid'
        value = 12 )

      ( client = sy-mandt stardust_id = '0000001002'
        collection_id = '0000000101'
        color = 'Purple'
        weight = '5.20'
        state_of_matter = 'Gas'
        value = 80 )

      ( client = sy-mandt stardust_id = '0000001003'
        collection_id = '0000000102'
        color = 'Gold'
        weight = '12.00'
        state_of_matter = 'Liquid'
        value = 25 )

      ( client = sy-mandt stardust_id = '0000001004'
        collection_id = '0000000103'
        color = 'Green'
        weight = '7.75'
        state_of_matter = 'Solid'
        value = 15 )
    ).

    MODIFY zka0622_t_sdust FROM TABLE @lt_sdust.

    COMMIT WORK.

    out->write( 'Test data inserted successfully.' ).


  COMMIT WORK.


  ENDMETHOD.

ENDCLASS.
