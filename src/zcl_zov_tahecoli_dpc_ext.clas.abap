class ZCL_ZOV_TAHECOLI_DPC_EXT definition
  public
  inheriting from ZCL_ZOV_TAHECOLI_DPC
  create public .

public section.
protected section.

  methods MENSAGEMSET_CREATE_ENTITY
    redefinition .
  methods MENSAGEMSET_DELETE_ENTITY
    redefinition .
  methods MENSAGEMSET_GET_ENTITY
    redefinition .
  methods MENSAGEMSET_GET_ENTITYSET
    redefinition .
  methods MENSAGEMSET_UPDATE_ENTITY
    redefinition .
  methods OVCABSET_CREATE_ENTITY
    redefinition .
  methods OVCABSET_DELETE_ENTITY
    redefinition .
  methods OVCABSET_GET_ENTITY
    redefinition .
  methods OVCABSET_GET_ENTITYSET
    redefinition .
  methods OVCABSET_UPDATE_ENTITY
    redefinition .
  methods OVITEMSET_CREATE_ENTITY
    redefinition .
  methods OVITEMSET_DELETE_ENTITY
    redefinition .
  methods OVITEMSET_GET_ENTITY
    redefinition .
  methods OVITEMSET_GET_ENTITYSET
    redefinition .
  methods OVITEMSET_UPDATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZOV_TAHECOLI_DPC_EXT IMPLEMENTATION.


  method MENSAGEMSET_CREATE_ENTITY.

  endmethod.


  method MENSAGEMSET_DELETE_ENTITY.

  endmethod.


  method MENSAGEMSET_GET_ENTITY.

  endmethod.


  method MENSAGEMSET_GET_ENTITYSET.

  endmethod.


  method MENSAGEMSET_UPDATE_ENTITY.

  endmethod.


  METHOD ovcabset_create_entity.
    DATA: ld_lastid TYPE int4.
    DATA: ls_cab TYPE zovcab_tahecoli.


    "cria objeto de msg
    DATA(lo_msg) = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    io_data_provider->read_entry_data(
      IMPORTING
        es_data = er_entity
    ).

    MOVE-CORRESPONDING er_entity TO ls_cab.

    ls_Cab-criacao_data = sy-datum.
    ls_cab-criacao_hora = sy-uzeit.
    ls_cab-criacao_usuario = sy-uname.

    "Seleciona maior ID da tabela
    SELECT SINGLE MAX( ordemid )
    INTO ld_lastid
      FROM     zovcab_tahecoli.

    "Faz incremento de id
    ls_cab-ordemid = ld_lastid + 1.
    INSERT zovcab_tahecoli FROM ls_cab.
    IF sy-subrc <> 0.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type               =    'E'
          iv_msg_text               =    'Erro ao inserir ordem'
      ).

      "Em casode erro passa o objeto de msg para a exception
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.

    "Devolve para o retorno
    MOVE-CORRESPONDING ls_cab TO er_entity.

    "Converte o timestemp
    CONVERT
    DATE ls_cab-criacao_data
    TIME ls_cab-criacao_hora
    INTO TIME STAMP er_entity-datacriacao
    TIME ZONE sy-zonlo.


  ENDMETHOD.


  METHOD ovcabset_delete_entity.
    DATA: ls_key_tab LIKE LINE OF it_key_tab.

    DATA(lo_msg) =  me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'OrdemID'. "igual na SEGW
    IF sy-subrc <> 0.

      lo_msg->add_message_text_only(
      EXPORTING
        iv_msg_type = 'E'
        iv_msg_text = 'OrdemId não informado'
      ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.

    DELETE FROM zovitem_tahecoli WHERE ordemitem = ls_key_tab-value.
 " Taglys 22/10/2025 - Comentando validação pois algumas ordens podem
 " não tem itens
*    IF sy-subrc <> 0.
*      ROLLBACK WORK.
*
*      lo_msg->add_message_text_only(
*      EXPORTING
*        iv_msg_type = 'E'
*        iv_msg_text = 'Erro ao remover itens'
*      ).
*      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*        EXPORTING
*          message_container = lo_msg.
*    ENDIF.

    DELETE FROM zovcab_tahecoli WHERE ordemid = ls_key_tab-value.

    IF sy-subrc <> 0.
      ROLLBACK WORK.

      lo_msg->add_message_text_only(
      EXPORTING
        iv_msg_type = 'E'
        iv_msg_text = 'Erro ao remover Ordem'
      ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.
    COMMIT WORK AND WAIT.
  ENDMETHOD.


  METHOD ovcabset_get_entity.

    DATA: ld_ordemid TYPE zovcab_tahecoli-ordemid,
          ls_key_tab LIKE LINE OF it_key_tab,
          ls_cab     TYPE zovcab_tahecoli.

    DATA(lo_msg) = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'OrdemID'.
    IF sy-subrc <> 0.
      lo_msg->add_message_text_only(
      EXPORTING
        iv_msg_type = 'E'
        iv_msg_text = 'Id da ordem não informado'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.
    ld_ordemid = ls_key_tab-value.


    SELECT SINGLE *
      INTO ls_cab
      FROM zovcab_tahecoli
      WHERE ordemid = ld_ordemid.

    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_cab TO er_entity.

      er_entity-criadopor = ls_cab-criacao_usuario.

      CONVERT DATE ls_cab-criacao_data
              TIME ls_cab-criacao_hora
              INTO TIME STAMP er_entity-datacriacao
              TIME ZONE sy-zonlo.
    ELSE.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'Id da ordem não encontrado'
        ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.

  ENDMETHOD.


  METHOD ovcabset_get_entityset.
    DATA: lt_cab TYPE STANDARD TABLE OF zovcab_tahecoli.
    DATA: ls_cab TYPE zovcab_tahecoli.
    DATA: ls_entityset LIKE LINE OF et_entityset.

*--------- LOGICA DE ORDENAÇÃO ---------*
    DATA: lt_orderby TYPE STANDARD TABLE OF string.
    DATA: ld_orderby TYPE string.

    LOOP AT it_order INTO DATA(ls_order).
      TRANSLATE ls_order-property TO UPPER CASE. "Aqui chega clienteId por exemplo o campo que quero ordernar
      TRANSLATE ls_order-order TO UPPER CASE.    "Aqui Desc ou Asc o sentido
      IF ls_order-order = 'DESC'.
        ls_order-order = 'DESCENDING'.           "Tipo aceito no select
      ELSE.
        ls_order-order = 'ASCENDING'.            "Tipo aceito no select
      ENDIF.
      APPEND |{ ls_order-property } { ls_order-order }|
      TO lt_orderby.
    ENDLOOP.
    CONCATENATE LINES OF lt_orderby INTO  ld_orderby SEPARATED BY ''.
*--------- LOGICA DE ORDENAÇÃO ---------*

    "Ordenação obrigatoria caso nenhuma seja definida para nao dar erro, por conta do offset.
    IF ld_orderby = ''.
      ld_orderby = 'OrdemID ASCENDING'.
    ENDIF.

    SELECT *
      FROM zovcab_tahecoli
      WHERE (iv_filter_string)       "parametro de filtro
      ORDER BY (ld_orderby)          "parametro de filtro
      INTO TABLE @lt_cab
      UP TO @is_paging-top ROWS     " Paginação top pega as primeiras
      OFFSET @is_paging-skip.       " Paginação skip pula as primeiras


    LOOP AT lt_cab INTO ls_cab.
      CLEAR ls_entityset.
      MOVE-CORRESPONDING ls_cab TO ls_entityset.

      ls_entityset-criadopor = ls_cab-criacao_usuario.

      CONVERT
      DATE ls_cab-criacao_data
      TIME ls_cab-criacao_hora
      INTO TIME STAMP ls_entityset-datacriacao
      TIME ZONE sy-zonlo.

      APPEND ls_entityset TO et_entityset.
    ENDLOOP.
  ENDMETHOD.


  METHOD ovcabset_update_entity.

    DATA(lo_msg) = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    io_data_provider->read_entry_data(
      IMPORTING
        es_data = er_entity
    ).

    er_entity-ordemid = it_key_tab[ name = 'OrdemID' ]-value.

    UPDATE zovcab_tahecoli
      SET clienteid = er_entity-clienteid
          totalitens = er_entity-totalfrete
          totalordem = er_entity-totalordem
          status = er_entity-status
          WHERE ordemid = er_entity-ordemid.

    IF sy-subrc <> 0.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type       =  'E'
          iv_msg_text       =  'Erro ao atualizar ordem'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.
  ENDMETHOD.


  METHOD ovitemset_create_entity.

    DATA: ls_item TYPE zovitem_tahecoli.

    DATA(lo_msg) = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    io_data_provider->read_entry_data(
      IMPORTING
        es_data = er_entity                           "er_entity estrutura de retorno.
    ).
*  CATCH /iwbep/cx_mgw_tech_exception. " mgw technical exception

    MOVE-CORRESPONDING er_entity TO ls_item.
    ls_item-ordemitem = er_entity-ordemid.
    IF er_entity-itemid = 0.
      SELECT SINGLE MAX( itemid )
        INTO er_entity-itemid
        FROM zovitem_tahecoli
        WHERE ordemitem = er_entity-ordemid.

      er_entity-itemid = er_entity-itemid + 1.
    ENDIF.

    INSERT zovitem_tahecoli FROM ls_item.
    IF sy-subrc <> 0.
      lo_msg->add_message_text_only(
      EXPORTING
        iv_msg_type = 'E'
        iv_msg_text = 'Erro ao inserir item'
).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.
  ENDMETHOD.


  METHOD ovitemset_delete_entity.
    DATA: ls_key_tab LIKE LINE OF it_key_tab.

    DATA(lo_msg) =  me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    DATA(lv_ordemitem) = it_key_tab[ name = 'OrdemId' ]-value. "como na SEGW
    DATA(lv_itemid)    = it_key_tab[ name = 'ItemId' ]-value.  "como na SEGW

    DELETE FROM zovitem_tahecoli
    WHERE ordemitem = lv_ordemitem
    AND itemid = lv_itemid.

    IF sy-subrc <> 0.
      lo_msg->add_message_text_only(
      EXPORTING
        iv_msg_type = 'E'
        iv_msg_text = 'Erro ao remover item'
      ).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.
  ENDMETHOD.


  METHOD ovitemset_get_entity.
    DATA: ls_key_tab LIKE LINE OF it_key_tab,
          ls_item    TYPE zovitem_tahecoli,
          ld_error   TYPE flag.

    DATA(lo_msg) =  me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'OrdemId'.
    IF sy-subrc <> 0.
      ld_error = 'X'.
      lo_msg->add_message_text_only(
      EXPORTING
        iv_msg_type = 'E'
        iv_msg_text = 'Campo chave Ordem Item nao informado'
      ).
    ENDIF.
    ls_item-ordemitem = ls_key_tab-value.

    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'ItemId'.
    IF sy-subrc <> 0.
      ld_error = 'X'.
      lo_msg->add_message_text_only(
      EXPORTING
        iv_msg_type = 'E'
        iv_msg_text = 'Campo chave Item Id não informado'
      ).
    ENDIF.
    ls_item-itemid = ls_key_tab-value.

    IF ld_error = 'X'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.

    SELECT SINGLE *
      INTO ls_item
      FROM zovitem_tahecoli
      WHERE ordemitem = ls_item-ordemitem
      AND   itemid    = ls_item-itemid.

    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_item TO er_entity.
      er_entity-ordemid = ls_item-ordemitem.
    ELSE.
      lo_msg->add_message_text_only(
    EXPORTING
      iv_msg_type = 'E'
      iv_msg_text = 'Item não encontrado'
).
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
      EXPORTING
      message_container = lo_msg.

    ENDIF.
  ENDMETHOD.


  METHOD ovitemset_get_entityset.

    DATA: ld_ordemid       TYPE int4,
          lt_ordemid_range TYPE RANGE OF int4,
          ls_ordemid_range LIKE LINE OF lt_ordemid_range,
          ls_key_tab       LIKE LINE OF it_key_tab.


    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'OrdemID'.
    IF sy-subrc = 0 .
      ld_ordemid = ls_key_tab-value.

      CLEAR ls_ordemid_range.
      ls_ordemid_range-sign = 'I'.
      ls_ordemid_range-option = 'EQ'.
      ls_ordemid_range-low = ld_ordemid.

      APPEND ls_ordemid_range TO lt_ordemid_range.
    ENDIF.

    SELECT *
    INTO CORRESPONDING FIELDS OF TABLE et_entityset
    FROM zovitem_tahecoli
   WHERE ordemitem IN lt_ordemid_range.

  ENDMETHOD.


  METHOD ovitemset_update_entity.

    DATA(lo_msg) = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    io_data_provider->read_entry_data(
      IMPORTING
        es_data = er_entity
    ).

    er_entity-ordemid  = it_key_tab[ name = 'OrdemId' ]-value.   "Chaves que vem da URI
    er_entity-itemid   = it_key_tab[ name = 'ItemId' ]-value.    "Chaves que vem da URI
    er_entity-precotot = er_entity-quantidade * er_entity-precouni.

    UPDATE zovitem_tahecoli
      SET material        = er_entity-material
          descricao       = er_entity-descricao
          quantidade      = er_entity-quantidade
          precouni        = er_entity-precouni
          precotot        = er_entity-precotot
   WHERE ordemitem        = er_entity-ordemid
     AND itemid           = er_entity-itemid.

    IF sy-subrc <> 0.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type       =  'E'
          iv_msg_text       =  'Erro ao atualizar item'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
