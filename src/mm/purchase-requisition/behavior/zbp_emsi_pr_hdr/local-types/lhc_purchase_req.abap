CLASS lhc_PurchaseReq DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.

    METHODS CREATE FOR MODIFY
      IMPORTING ENTITIES FOR CREATE PurchaseReq.

    METHODS DELETE FOR MODIFY
      IMPORTING KEYS FOR DELETE PurchaseReq.

    METHODS UPDATE FOR MODIFY
      IMPORTING ENTITIES FOR UPDATE PurchaseReq.

    METHODS READ FOR READ
      IMPORTING KEYS FOR READ PurchaseReq RESULT RESULT.

    METHODS cba_ITEM FOR MODIFY
      IMPORTING ENTITIES_CBA FOR CREATE PurchaseReq\_ITEM.

    METHODS rba_ITEM FOR READ
      IMPORTING KEYS_RBA FOR READ PurchaseReq\_ITEM FULL RESULT_REQUESTED RESULT RESULT LINK ASSOCIATION_LINKS.

ENDCLASS.

CLASS lhc_PurchaseReq IMPLEMENTATION.

  METHOD CREATE.

    DATA LV_TIMESTAMP TYPE TIMESTAMPL.
    DATA LV_UUID TYPE SYSUUID_X16.

    GET TIME STAMP FIELD LV_TIMESTAMP.

    LOOP AT ENTITIES INTO DATA(ENTITY).

      "------------------------------------------------------------
      " 1. Generate technical identity (Early Numbering)
      "------------------------------------------------------------
      CLEAR LV_UUID.

      TRY.
          LV_UUID = CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC(  ).

        CATCH CX_UUID_ERROR.
          APPEND VALUE #( %CID = ENTITY-%CID ) TO FAILED-PURCHASEREQ.

          CONTINUE.

      ENDTRY.

      "------------------------------------------------------------
      " 2. Build the transactional persistence representation
      "------------------------------------------------------------
      INSERT VALUE #(
        CLIENT = SY-MANDT
        PURCHASE_REQ_UUID = LV_UUID

        " Business identifier is assigned only on Submit
        PURCHASE_REQ_NO = ''

        " Business data received from the consumer
        DESCRIPTION = ENTITY-Description
        COMPANY_CODE = ENTITY-CompanyCode
        PLANT = ENTITY-Plant
        REQUESTED_BY = ENTITY-RequestedBy

        " Initial business state
        STATUS = 'C'

        " Administrative fields
        CREATED_BY = SY-UNAME
        CREATED_AT = LV_TIMESTAMP
        LAST_CHANGED_BY = SY-UNAME
        LAST_CHANGED_AT = LV_TIMESTAMP
        LOCAL_LAST_CHANGED_AT = LV_TIMESTAMP

        " Transactional buffer state
        OPERATION = LCL_BUFFER=>GC_CREATE

       ) INTO TABLE LCL_BUFFER=>GT_PR_HEADER.

      "------------------------------------------------------------
      " 3. Return RAP correlation ID → generated UUID mapping
      "------------------------------------------------------------
      INSERT VALUE #(
        %CID = ENTITY-%CID
        PURCHASEREQUUID = LV_UUID
       ) INTO TABLE MAPPED-PURCHASEREQ.

    ENDLOOP.

  ENDMETHOD.

  METHOD DELETE.

    LOOP AT KEYS INTO DATA(KEY).

      "------------------------------------------------------------
      " 1. Check transactional buffer first
      "------------------------------------------------------------
      READ TABLE LCL_BUFFER=>GT_PR_HEADER
        WITH TABLE KEY
            CLIENT = SY-MANDT
            PURCHASE_REQ_UUID = KEY-PurchaseReqUuid
        INTO DATA(LS_BUFFER).

      IF SY-SUBRC = 0.

        "----------------------------------------------------------
        " 2. CREATE -> DELETE = no net persistence operation
        "----------------------------------------------------------
        IF LS_BUFFER-OPERATION = LCL_BUFFER=>GC_CREATE.

          DELETE TABLE LCL_BUFFER=>GT_PR_HEADER
              WITH TABLE KEY
                CLIENT = SY-MANDT
                PURCHASE_REQ_UUID = KEY-PurchaseReqUuid.

          CONTINUE.

        ENDIF.

        "----------------------------------------------------------
        " 3. Existing transactional instance -> mark for deletion
        "----------------------------------------------------------
        LS_BUFFER-OPERATION = LCL_BUFFER=>GC_DELETE.

        MODIFY TABLE LCL_BUFFER=>GT_PR_HEADER FROM LS_BUFFER.

        CONTINUE.

      ENDIF.

      "------------------------------------------------------------
      " 4. Not buffered -> check persisted state
      "------------------------------------------------------------
      SELECT SINGLE *
        FROM ZEMST_PR_HDR
            WHERE Purchase_Req_Uuid = @KEY-PurchaseReqUuid
        INTO @DATA(LS_DB).

      IF SY-SUBRC <> 0.
        APPEND VALUE #(
            PURCHASEREQUUID = KEY-PurchaseReqUuid
        ) TO FAILED-PURCHASEREQ.

        CONTINUE.

      ENDIF.

      "------------------------------------------------------------
      " 5. Add persisted instance to buffer as DELETE
      "------------------------------------------------------------
      CLEAR LS_BUFFER.

      MOVE-CORRESPONDING LS_DB TO LS_BUFFER.

      LS_BUFFER-OPERATION = LCL_BUFFER=>GC_DELETE.

      INSERT LS_BUFFER
        INTO TABLE LCL_BUFFER=>GT_PR_HEADER.

    ENDLOOP.

  ENDMETHOD.

  METHOD UPDATE.

    DATA LV_TIMESTAMP TYPE TIMESTAMPL.

    GET TIME STAMP FIELD LV_TIMESTAMP.

    LOOP AT ENTITIES INTO DATA(ENTITY).

      "------------------------------------------------------------
      " 1. Try current transactional state first
      "------------------------------------------------------------
      READ TABLE LCL_BUFFER=>GT_PR_HEADER
        WITH KEY
            CLIENT = SY-MANDT
            PURCHASE_REQ_UUID = ENTITY-PurchaseReqUuid
        ASSIGNING FIELD-SYMBOL(<BUFFER>).

      "------------------------------------------------------------
      " 2. If not buffered, load persisted state
      "------------------------------------------------------------
      IF SY-SUBRC <> 0.

        SELECT SINGLE *
        FROM ZEMST_PR_HDR
        WHERE PURCHASE_REQ_UUID = @ENTITY-purchaseReqUuid
        INTO @DATA(LS_DB).

        IF SY-SUBRC <> 0.

          APPEND VALUE #(
              PurchaseReqUuid = ENTITY-PurchaseReqUuid
           ) TO FAILED-PURCHASEREQ.

          CONTINUE.

        ENDIF.

        DATA(LS_NEW_BUFFER) = CORRESPONDING LCL_BUFFER=>TY_PR_HEADER( LS_DB ).

        LS_NEW_BUFFER-OPERATION = LCL_BUFFER=>GC_UPDATE.

        INSERT LS_NEW_BUFFER
            INTO TABLE LCL_BUFFER=>GT_PR_HEADER ASSIGNING <BUFFER>.

      ENDIF.

      "------------------------------------------------------------
      " 3. Apply only explicitly changed fields
      "------------------------------------------------------------
      IF ENTITY-%CONTROL-Description = IF_ABAP_BEHV=>MK-ON.
        <BUFFER>-DESCRIPTION = ENTITY-Description.
      ENDIF.

      IF ENTITY-%CONTROL-CompanyCode = IF_ABAP_BEHV=>MK-ON.
        <BUFFER>-COMPANY_CODE = ENTITY-CompanyCode.
      ENDIF.

      IF ENTITY-%CONTROL-Plant = IF_ABAP_BEHV=>MK-ON.
        <BUFFER>-PLANT = ENTITY-Plant.
      ENDIF.

      IF ENTITY-%CONTROL-RequestedBy = IF_ABAP_BEHV=>MK-ON.
        <BUFFER>-REQUESTED_BY = ENTITY-RequestedBy.
      ENDIF.

      "------------------------------------------------------------
      " 4. Administrative fields
      "------------------------------------------------------------
      <BUFFER>-LAST_CHANGED_BY = SY-UNAME.
      <BUFFER>-LAST_CHANGED_AT = LV_TIMESTAMP.
      <BUFFER>-LOCAL_LAST_CHANGED_AT = LV_TIMESTAMP.

      "------------------------------------------------------------
      " 5. Preserve CREATE state when appropriate
      "------------------------------------------------------------
      IF <BUFFER>-OPERATION <> LCL_BUFFER=>GC_CREATE.
        <BUFFER>-OPERATION = LCL_BUFFER=>GC_UPDATE.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD READ.

    LOOP AT KEYS INTO DATA(KEY).
      "------------------------------------------------------------
      " 1. Check transactional buffer first
      "------------------------------------------------------------
      READ TABLE LCL_BUFFER=>GT_PR_HEADER
        WITH KEY
            CLIENT = SY-MANDT
            PURCHASE_REQ_UUID = KEY-PurchaseReqUuid
        INTO DATA(LS_BUFFER).

      IF SY-SUBRC = 0.
        " Deleted instances must no longer be visible
        IF LS_BUFFER-OPERATION = LCL_BUFFER=>GC_DELETE.
          CONTINUE.
        ENDIF.

        APPEND VALUE #(
            PURCHASEREQUUID = LS_BUFFER-PURCHASE_REQ_UUID
            PURCHASEREQNO = LS_BUFFER-PURCHASE_REQ_NO
            DESCRIPTION = LS_BUFFER-DESCRIPTION
            STATUS = LS_BUFFER-STATUS
            COMPANYCODE = LS_BUFFER-COMPANY_CODE
            PLANT = LS_BUFFER-PLANT
            REQUESTEDBY = LS_BUFFER-REQUESTED_BY
            CREATEDBY = LS_BUFFER-CREATED_BY
            CREATEDAT = LS_BUFFER-CREATED_AT
            LASTCHANGEDBY = LS_BUFFER-LAST_CHANGED_BY
            LASTCHANGEDAT = LS_BUFFER-LAST_CHANGED_AT
            LOCALLASTCHANGEDAT = LS_BUFFER-LOCAL_LAST_CHANGED_AT
         ) TO RESULT.

        CONTINUE.

      ENDIF.

      "------------------------------------------------------------
      " 2. Not buffered -> read persisted state
      "------------------------------------------------------------
      SELECT SINGLE
        FROM ZEMST_PR_HDR
        FIELDS
            PURCHASE_REQ_UUID,
            PURCHASE_REQ_NO,
            DESCRIPTION,
            STATUS,
            COMPANY_CODE,
            PLANT,
            REQUESTED_BY,
            CREATED_BY,
            CREATED_AT,
            LAST_CHANGED_BY,
            LAST_CHANGED_at,
            LOCAL_LAST_CHANGED_AT
        WHERE PURCHASE_REQ_UUID = @KEY-PurchaseReqUuid
        INTO @DATA(LS_DB).

      IF SY-SUBRC = 0.

        APPEND VALUE #(
            PURCHASEREQUUID = LS_DB-PURCHASE_REQ_UUID
            PURCHASEREQNO = LS_DB-PURCHASE_REQ_NO
            DESCRIPTION = LS_DB-DESCRIPTION
            STATUS = LS_DB-STATUS
            COMPANYCODE = LS_DB-COMPANY_CODE
            PLANT = LS_DB-PLANT
            REQUESTEDBY = LS_DB-REQUESTED_BY
            CREATEDBY = LS_DB-CREATED_BY
            CREATEDAT = LS_DB-CREATED_AT
            LASTCHANGEDBY = LS_db-LAST_CHANGED_BY
            LASTCHANGEDAT = LS_DB-LAST_CHANGED_AT
            LOCALLASTCHANGEDAT = LS_DB-LOCAL_LAST_CHANGED_AT
         ) TO RESULT.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD cba_ITEM.
  ENDMETHOD.

  METHOD rba_ITEM.
  ENDMETHOD.

ENDCLASS.
