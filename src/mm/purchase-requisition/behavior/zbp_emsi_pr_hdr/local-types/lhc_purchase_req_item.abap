CLASS lhc_PurchaseReqItem DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE PurchaseReqItem.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE PurchaseReqItem.

    METHODS read FOR READ
      IMPORTING keys FOR READ PurchaseReqItem RESULT result.

ENDCLASS.


CLASS lhc_PurchaseReqItem IMPLEMENTATION.

  METHOD delete.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

ENDCLASS.