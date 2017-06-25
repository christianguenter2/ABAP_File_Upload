*&---------------------------------------------------------------------*
*& Report z_file_upload_test
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_file_upload_test.

PARAMETERS: p_file TYPE string LOWER CASE OBLIGATORY DEFAULT  `/tmp/CSV/data.csv`.

CLASS controller DEFINITION CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS:
      start,

      handle_data_read FOR EVENT data_read OF zcl_server_file_upload
        IMPORTING
            et_data.

  PRIVATE SECTION.
    DATA: m_chunks_read TYPE i.

ENDCLASS.

CLASS controller IMPLEMENTATION.

  METHOD start.

    DATA(file_reader) = NEW zcl_server_file_upload( p_file ).

    SET HANDLER handle_data_read FOR file_reader.

    TRY.
        file_reader->start_upload_chunk( i_chunk_size = 20 ).

      CATCH zcx_file_upload_error INTO DATA(error).
        MESSAGE error->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

    cl_demo_output=>display(  ).

  ENDMETHOD.

  METHOD handle_data_read.

    m_chunks_read = m_chunks_read + 1.

    cl_demo_output=>write( |Count of chunks { m_chunks_read }| ).
    cl_demo_output=>write( |Lines { lines( et_data ) }| ).
    cl_demo_output=>write( et_data ).

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.
  NEW controller( )->start( ).
