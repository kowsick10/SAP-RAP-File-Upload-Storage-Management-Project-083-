CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA: mt_buffer_create TYPE TABLE OF zfile_store_083,
                mt_buffer_update TYPE TABLE OF zfile_store_083,
                mt_buffer_delete TYPE TABLE OF zfile_store_083.
ENDCLASS.

CLASS lhc_FileStore DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR FileStore RESULT result.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR FileStore RESULT result.
    METHODS create FOR MODIFY IMPORTING entities FOR CREATE FileStore.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE FileStore.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE FileStore.
    METHODS read   FOR READ   IMPORTING keys FOR READ FileStore RESULT result.
    METHODS lock   FOR LOCK   IMPORTING keys FOR LOCK FileStore.
ENDCLASS.

CLASS lhc_FileStore IMPLEMENTATION.
  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( %tky = ls_key-%tky %update = if_abap_behv=>auth-allowed %delete = if_abap_behv=>auth-allowed ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD create.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      DATA(ls_file) = CORRESPONDING zfile_store_083( <ls_entity> MAPPING FROM ENTITY ).
      IF ls_file-file_id IS INITIAL.
        ls_file-file_id = cl_system_uuid=>create_uuid_x16_static( ).
      ENDIF.
      ls_file-file_size = xstrlen( ls_file-file_data ).
      ls_file-created_by = sy-uname.
      GET TIME STAMP FIELD ls_file-created_at.

      APPEND ls_file TO lcl_buffer=>mt_buffer_create.
      INSERT VALUE #( %cid = <ls_entity>-%cid FileId = ls_file-file_id ) INTO TABLE mapped-filestore.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      SELECT SINGLE * FROM zfile_store_083 WHERE file_id = @<ls_entity>-FileId INTO @DATA(ls_db).
      IF sy-subrc = 0.
        IF <ls_entity>-%control-FileName = if_abap_behv=>mk-on. ls_db-file_name = <ls_entity>-FileName. ENDIF.
        IF <ls_entity>-%control-MimeType = if_abap_behv=>mk-on. ls_db-mime_type = <ls_entity>-MimeType. ENDIF.
        IF <ls_entity>-%control-FileData = if_abap_behv=>mk-on.
            ls_db-file_data = <ls_entity>-FileData.
            ls_db-file_size = xstrlen( ls_db-file_data ).
        ENDIF.
        APPEND ls_db TO lcl_buffer=>mt_buffer_update.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( file_id = ls_key-FileId ) TO lcl_buffer=>mt_buffer_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF keys IS NOT INITIAL.
      SELECT * FROM zfile_store_083 FOR ALL ENTRIES IN @keys WHERE file_id = @keys-FileId INTO TABLE @DATA(lt_db).
      result = CORRESPONDING #( lt_db MAPPING TO ENTITY ).
    ENDIF.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_saver DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save REDEFINITION.
ENDCLASS.

CLASS lsc_saver IMPLEMENTATION.
  METHOD save.
    IF lcl_buffer=>mt_buffer_create IS NOT INITIAL. INSERT zfile_store_083 FROM TABLE @lcl_buffer=>mt_buffer_create. ENDIF.
    IF lcl_buffer=>mt_buffer_update IS NOT INITIAL. UPDATE zfile_store_083 FROM TABLE @lcl_buffer=>mt_buffer_update. ENDIF.
    IF lcl_buffer=>mt_buffer_delete IS NOT INITIAL. DELETE zfile_store_083 FROM TABLE @lcl_buffer=>mt_buffer_delete. ENDIF.
    CLEAR: lcl_buffer=>mt_buffer_create, lcl_buffer=>mt_buffer_update, lcl_buffer=>mt_buffer_delete.
  ENDMETHOD.
ENDCLASS.
