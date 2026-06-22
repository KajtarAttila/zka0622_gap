CLASS lhc_zka0622_vi_sfarer DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

"    METHODS set_id FOR DETERMINE ON MODIFY
"      IMPORTING keys FOR ZKA0622_VI_SFARER~set_id.

    METHODS prepare FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZKA0622_VI_SFARER~prepare.

    METHODS validate_reputation FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZKA0622_VI_SFARER~validate_reputation.

    METHODS get_instance_features
      FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZKA0622_VI_SFARER RESULT result.

ENDCLASS.

CLASS lhc_zka0622_vi_sfarer IMPLEMENTATION.

*METHOD set_id.
*
*
*  DATA lv_max TYPE zka0622_t_sfarer-spacefarer_id.
*
*  SELECT MAX( spacefarer_id )
*    FROM zka0622_t_sfarer
*    INTO @lv_max.
*
*
*  MODIFY ENTITIES OF zka0622_vi_sfarer
*    IN LOCAL MODE
*    ENTITY zka0622_vi_sfarer
*    UPDATE FIELDS ( spacefarer_id )
*    WITH VALUE #(
*      FOR k IN keys (
*        %tky = k-%tky
*      )
*    ).
*
*
*ENDMETHOD.

METHOD validate_reputation.

  READ ENTITIES OF ZKA0622_VI_SFARER
      IN LOCAL MODE
      ENTITY ZKA0622_VI_SFARER
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_data).

  LOOP AT lt_data INTO DATA(ls_data).

    IF ls_data-wormhole_skill + ls_data-reputation >= 99.

      APPEND VALUE #(
        %tky = ls_data-%tky
      ) TO failed-zka0622_vi_sfarer.

      APPEND VALUE #(
        %tky = ls_data-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = 'Navigation Skill + Reputation must be less than 99'
        )
      ) TO reported-zka0622_vi_sfarer.

    ENDIF.

 ENDLOOP.

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

METHOD prepare.

ENDMETHOD.

ENDCLASS.
