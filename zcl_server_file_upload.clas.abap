CLASS zcl_server_file_upload DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          i_file TYPE string,

      upload_complete
        RETURNING
          VALUE(rt_data) TYPE stringtab
        RAISING
          zcx_file_upload_error,

      start_upload_chunk
        IMPORTING
          i_chunk_size TYPE i
        RAISING
          zcx_file_upload_error.

    EVENTS:
      data_read
        EXPORTING
          VALUE(et_data) TYPE stringtab.

  PRIVATE SECTION.
    DATA:
      m_file TYPE string.

    METHODS:
      _open_dataset
        RAISING
          zcx_file_upload_error,

      _close_dataset
        RAISING
          zcx_file_upload_error.

ENDCLASS.



CLASS zcl_server_file_upload IMPLEMENTATION.

  METHOD constructor.

    m_file = i_file.

  ENDMETHOD.

  METHOD upload_complete.

    DATA: line LIKE LINE OF rt_data.

    _open_dataset( ).

    DO.

      READ DATASET m_file INTO line.
      IF sy-subrc = 0.
        INSERT line INTO TABLE rt_data.
      ELSE.
        EXIT.
      ENDIF.

    ENDDO.

    _close_dataset( ).

  ENDMETHOD.

  METHOD start_upload_chunk.

    DATA: lt_data TYPE stringtab,
          line    LIKE LINE OF lt_data.

    _open_dataset( ).

    DO.

      READ DATASET m_file INTO line.
      IF sy-subrc = 0.
        INSERT line INTO TABLE lt_data.
      ELSE.
        EXIT.
      ENDIF.

      IF lines( lt_data ) = i_chunk_size.

        RAISE EVENT data_read
          EXPORTING
            et_data = lt_data.

        CLEAR lt_data.

      ENDIF.

    ENDDO.

    IF lines( lt_data ) > 0.

      RAISE EVENT data_read
        EXPORTING
          et_data = lt_data.

    ENDIF.

    _close_dataset( ).

  ENDMETHOD.

  METHOD _open_dataset.

    OPEN DATASET m_file FOR INPUT IN TEXT MODE
                        ENCODING UTF-8.
    IF sy-subrc <> 0.
      zcx_file_upload_error=>raise_file_open_error( m_file ).
    ENDIF.

  ENDMETHOD.

  METHOD _close_dataset.

    CLOSE DATASET m_file.
    IF sy-subrc <> 0.
      zcx_file_upload_error=>raise_file_close_error( m_file ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
