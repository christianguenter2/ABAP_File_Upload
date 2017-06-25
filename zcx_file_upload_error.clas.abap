CLASS zcx_file_upload_error DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES:
      if_t100_dyn_msg,
      if_t100_message.

    CLASS-METHODS:
      raise_file_open_error
        IMPORTING
          i_file TYPE csequence
        RAISING
          zcx_file_upload_error,

      raise_syst
        RAISING
          zcx_file_upload_error,

      raise_file_close_error
        IMPORTING
          i_file TYPE string
        RAISING
          zcx_file_upload_error.

    METHODS:
      constructor
        IMPORTING
          !textid   LIKE if_t100_message=>t100key OPTIONAL
          !previous LIKE previous OPTIONAL
          msg       TYPE symsg OPTIONAL,

      get_text REDEFINITION.

  PRIVATE SECTION.
    DATA: m_msg TYPE symsg.

    METHODS:
      _get_msg_text
        RETURNING
          VALUE(r_text) TYPE string.

ENDCLASS.



CLASS zcx_file_upload_error IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( previous = previous ).

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    m_msg = msg.

  ENDMETHOD.


  METHOD get_text.

    result = COND #( WHEN m_msg IS NOT INITIAL THEN _get_msg_text( )
                     ELSE super->get_text( ) ).

  ENDMETHOD.


  METHOD raise_file_close_error.

    " Error while closing file &1
    MESSAGE e001(zfile_upload) WITH i_file
                               INTO DATA(dummy).
    zcx_file_upload_error=>raise_syst( ).

  ENDMETHOD.


  METHOD raise_file_open_error.

    " Error while opening file &1
    MESSAGE e000(zfile_upload) WITH i_file
                               INTO DATA(dummy).
    zcx_file_upload_error=>raise_syst( ).

  ENDMETHOD.


  METHOD raise_syst.

    DATA(msg) = VALUE symsg( msgty = sy-msgty
                             msgid = sy-msgid
                             msgno = sy-msgno
                             msgv1 = sy-msgv1
                             msgv2 = sy-msgv2
                             msgv3 = sy-msgv3
                             msgv4 = sy-msgv4 ).

    RAISE EXCEPTION TYPE zcx_file_upload_error
      EXPORTING
        msg = msg.

  ENDMETHOD.


  METHOD _get_msg_text.

    MESSAGE ID m_msg-msgid TYPE m_msg-msgty NUMBER m_msg-msgno
            WITH m_msg-msgv1 m_msg-msgv2 m_msg-msgv3 m_msg-msgv4
            INTO r_text.

  ENDMETHOD.

ENDCLASS.
