class ZCL_ZOV_TAHECOLI_MPC_EXT definition
  public
  inheriting from ZCL_ZOV_TAHECOLI_MPC
  create public .

public section.

  types:
    BEGIN OF ty_ordem_item,
        ordemid     TYPE i,
        datacriacao TYPE timestamp,
        criadopor   TYPE c LENGTH 20,
        clienteid   TYPE i,
        totalitens  TYPE p LENGTH 8 DECIMALS 2,
        totalfrete  TYPE p LENGTH 8 DECIMALS 2,
        totalordem  TYPE p LENGTH 8 DECIMALS 2,
        status      TYPE c LENGTH 1,
        toovitem    TYPE TABLE OF ts_ovitem WITH DEFAULT KEY,
      END OF ty_ordem_item .

  methods DEFINE
    redefinition .
protected section.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZOV_TAHECOLI_MPC_EXT IMPLEMENTATION.


  method DEFINE.
   data lo_entity_type type ref to /iwbep/if_mgw_odata_entity_typ.

   super->define( ). "Chama metodo da classe pai, tem que fazer.

   lo_entity_type = model->get_entity_type( iv_entity_name = 'OVCab' ). "cria objeto de cabeçalho.
   lo_entity_type->bind_structure( iv_structure_name = 'ZCL_ZOV_TAHECOLI_MPC_EXT=>TY_ORDEM_ITEM' ). " binda a estrutura criada
  endmethod.
ENDCLASS.
