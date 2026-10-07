CLASS LTCL_PURCHASE_REQ DEFINITION FINAL
 FOR TESTING
  DURATION SHORT
   RISK LEVEL HARMLESS.

  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA
         GO_CDS_ENVIRONMENT TYPE REF TO IF_CDS_TEST_ENVIRONMENT.

    CLASS-METHODS:
      CLASS_SETUP,
      CLASS_TEARDOWN.

    METHODS:
      SETUP,
      TEARDOWN,

      CREATE_HEADER FOR TESTING,
      READ_CREATED_HEADER FOR TESTING,
      UPDATE_CREATED_HEADER FOR TESTING,
      CREATE_DELETE_HEADER FOR TESTING,
      DELETE_PERSISTED_HEADER FOR TESTING,
      UPDATE_PERSISTED_HEADER FOR TESTING,
      SAVE_CREATED_HEADER FOR TESTING,
      SAVE_UPDATED_HEADER FOR TESTING,
      SAVE_DELETED_HEADER FOR TESTING.

ENDCLASS.

CLASS LTCL_PURCHASE_REQ IMPLEMENTATION.

  METHOD CLASS_SETUP.

    GO_CDS_ENVIRONMENT = CL_CDS_TEST_ENVIRONMENT=>CREATE(
        I_FOR_ENTITY = 'ZEMSI_PR_HDR'
     ).

    GO_CDS_ENVIRONMENT->ENABLE_DOUBLE_REDIRECTION(  ).

  ENDMETHOD.

  METHOD CLASS_TEARDOWN.

    GO_CDS_ENVIRONMENT->DESTROY(  ).

  ENDMETHOD.

  METHOD SETUP.

    LCL_BUFFER=>CLEAN_BUFFER(  ).

    GO_CDS_ENVIRONMENT->CLEAR_DOUBLES(  ).

  ENDMETHOD.

  METHOD TEARDOWN.

    ROLLBACK ENTITIES.

    LCL_BUFFER=>CLEAN_BUFFER(  ).

  ENDMETHOD.

  METHOD CREATE_HEADER.
    "------------------------------------------------------------
    " Act
    "------------------------------------------------------------
    MODIFY ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
            CREATE FIELDS (
                Description
                CompanyCode
                Plant
                RequestedBy
            )
            WITH VALUE #(
             (
                %CID = 'PR001'
                Description = 'EMS Test Purchase Requisition'
                CompanyCode = 'C001'
                Plant = 'P001'
                RequestedBy = SY-UNAME
             )
            )

            MAPPED DATA(MAPPED)
            FAILED DATA(FAILED)
            REPORTED DATA(REPORTED).

    "------------------------------------------------------------
    " Assert - RAP result
    "------------------------------------------------------------
    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
        ACT = FAILED-PURCHASEREQ
        MSG = 'CREATE returned failed instances'
     ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
       EXP = 1
       ACT = LINES( MAPPED-PURCHASEREQ )
       MSG = 'Exactly one Header Should be mapped'
     ).

    DATA(LS_MAPPED) = MAPPED-PURCHASEREQ[ 1 ].

    CL_ABAP_UNIT_ASSERT=>ASSERT_NOT_INITIAL(
      ACT = LS_MAPPED-PurchaseReqUuid
      MSG = 'Purchase Requisition UUID was not generated'
     ).

    "------------------------------------------------------------
    " Assert - Transactional Buffer
    "------------------------------------------------------------
    READ TABLE LCL_BUFFER=>GT_PR_HEADER
        WITH KEY
            CLIENT = SY-MANDT
            PURCHASE_REQ_UUID = LS_MAPPED-PurchaseReqUuid
        INTO DATA(LS_BUFFER).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = 0
        ACT = SY-SUBRC
        MSG = 'Created Header was not found in transactional buffer'
     ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
       EXP = 'EMS Test Purchase Requisition'
       ACT = LS_BUFFER-DESCRIPTION
     ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
      EXP = 'C001'
      ACT = LS_BUFFER-COMPANY_CODE
     ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
     EXP = 'P001'
     ACT = LS_BUFFER-PLANT
     ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
       EXP = 'C'
       ACT = LS_BUFFER-STATUS
       MSG = 'Initial business status must be Created'
     ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
       EXP = LCL_BUFFER=>GC_CREATE
       ACT = LS_BUFFER-OPERATION
       MSG = 'Buffer operation must be CREATE'
     ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
       ACT = LS_BUFFER-PURCHASE_REQ_NO
       MSG = 'Business number must not be generated during CREATE'
     ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
       EXP = SY-UNAME
       ACT = LS_BUFFER-CREATED_BY
     ).

    "------------------------------------------------------------
    " Assert - No database persistence during interaction phase
    "------------------------------------------------------------
    SELECT SINGLE PURCHASE_REQ_UUID
        FROM ZEMST_PR_HDR
        WHERE PURCHASE_REQ_UUID = @LS_MAPPED-PurchaseReqUuid
        INTO @DATA(LV_DB_UUID).


    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
        ACT = LV_DB_UUID
        MSG = 'Header must not be persisted before RAP save phase'
     ).

  ENDMETHOD.

*---------------------------------------------------------------------------

  METHOD READ_CREATED_HEADER.

    "------------------------------------------------------------
    " Arrange - Create Header in transactional buffer
    "------------------------------------------------------------
    MODIFY ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
            CREATE FIELDS (
                Description
                CompanyCode
                Plant
                RequestedBy
             )
             WITH VALUE #(
                (
                    %CID = 'PR001'
                    Description = 'EMS Transactional Read Test'
                    CompanyCode = 'C001'
                    Plant = 'P001'
                    RequestedBy = SY-UNAME
                 )
              )

              MAPPED DATA(MAPPED_CREATE)
              FAILED DATA(FAILED_CREATE)
              REPORTED DATA(REPORTed_create).

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
      ACT = FAILED_CREATE-PURCHASEREQ
     ).

    DATA(LS_MAPPED) = MAPPED_CREATE-PURCHASEREQ[ 1 ].

    "------------------------------------------------------------
    " Act - Read before SAVE
    "------------------------------------------------------------
    READ ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
            FIELDS (
                PurchaseReqUuid
                PurchaseReqNo
                Description
                Status
                CompanyCode
                Plant
                RequestedBy
             )
            WITH VALUE #(
                (
                    PurchaseReqUuid = LS_MAPPED-PurchaseReqUuid
                )
            )

            RESULT DATA(READ_RESULT)
            FAILED DATA(READ_FAILED)
            REPORTED DATA(READ_REPORTED).

    "------------------------------------------------------------
    " Assert
    "------------------------------------------------------------
    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
        ACT = READ_FAILED-PURCHASEREQ
        MSG = 'READ failed for buffered Purchase Requisition'
     ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = 1
        ACT = LINES( READ_RESULT )
        MSG = 'READ should return exactly one Purchase Requisition'
     ).

    DATA(LS_RESULT) = READ_RESULT[ 1 ].

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
       EXP = LS_MAPPED-PurchaseReqUuid
       ACT = LS_RESULT-PurchaseReqUuid
    ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = 'EMS Transactional Read Test'
        ACT = LS_RESULT-Description
    ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = 'C'
        ACT = LS_RESULT-Status
     ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
       EXP = 'C001'
       ACT = LS_RESULT-CompanyCode
     ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
       ACT = LS_RESULT-PurchaseReqNo
    ).


  ENDMETHOD.

  METHOD UPDATE_CREATED_HEADER.

    "------------------------------------------------------------
    " Arrange - Create
    "------------------------------------------------------------
    MODIFY ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
        CREATE FIELDS (
            Description
            CompanyCode
            Plant
            RequestedBy
         )
         WITH VALUE #(
            (
                %CID = 'PR001'
                Description = 'Original Description'
                CompanyCode = 'C001'
                Plant = 'P001'
                RequestedBy = SY-UNAME
            )
         )

         MAPPED DATA(MAPPED_CREATE)
         FAILED DATA(FAILED_CREATE)
         REPORTED DATA(REPORTED_CREATE).

    DATA(LS_MAPPED) = MAPPED_CREATE-PURCHASEREQ[ 1 ].

    "------------------------------------------------------------
    " Act - Update only Description
    "------------------------------------------------------------
    MODIFY ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
        UPDATE FIELDS (
            Description
        )
        WITH VALUE #(
            (
                PurchaseReqUuid = LS_MAPPED-PurchaseReqUuid
                Description = 'Updated Description'
            )
        )
        FAILED DATA(FAILED_UPDATE)
        REPORTED DATA(REPORTED_UPDATE).

    "------------------------------------------------------------
    " Act - Read updated transactional state
    "------------------------------------------------------------

    READ ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
        FIELDS (
            PurchaseReqUuid
            PurchaseReqNo
            Description
            Status
            CompanyCode
            Plant
            RequestedBy
        )
        WITH VALUE #(
            (
                PurchaseReqUuid = LS_MAPPED-PurchaseReqUuid
            )
         )
         RESULT DATA(READ_RESULT)
         FAILED DATA(FAILED_READ).

    "------------------------------------------------------------
    " Assert - Public RAP contract
    "------------------------------------------------------------
    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
    ACT = FAILED_UPDATE-PurchaseReq
  ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
      ACT = FAILED_READ-PurchaseReq
    ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
      EXP = 1
      ACT = LINES( READ_RESULT )
    ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
      EXP = 'Updated Description'
      ACT = READ_RESULT[ 1 ]-Description
    ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
      EXP = 'C001'
      ACT = READ_RESULT[ 1 ]-CompanyCode
    ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
      EXP = 'P001'
      ACT = READ_RESULT[ 1 ]-Plant
    ).

    "------------------------------------------------------------
    " Assert - Internal transactional state
    "------------------------------------------------------------
    DATA(LS_BUFFER) = LCL_BUFFER=>GT_PR_HEADER[
        CLIENT            = SY-MANDT
        PURCHASE_REQ_UUID = LS_MAPPED-PurchaseReqUuid
    ].

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = 'Updated Description'
        ACT = LS_BUFFER-DESCRIPTION
    ).

    " CREATE -> UPDATE must still be persisted as INSERT
    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
      EXP = LCL_BUFFER=>GC_CREATE
      ACT = LS_BUFFER-OPERATION
    ).

    " Unchanged fields must remain intact
    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
      EXP = 'C001'
      ACT = LS_BUFFER-COMPANY_CODE
    ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
      EXP = 'P001'
      ACT = LS_BUFFER-PLANT
    ).
  ENDMETHOD.

  METHOD CREATE_DELETE_HEADER.

    "------------------------------------------------------------
    " Arrange - Create Header
    "------------------------------------------------------------
    MODIFY ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
            CREATE FIELDS (
                Description
                CompanyCode
                PLANT
                REQUESTEDBY
            )
            WITH VALUE #(
                (
                    %CID = 'PR001'
                    Description = 'Delete Before Save Test'
                    CompanyCode = 'C001'
                    Plant = 'P001'
                    RequestedBy = SY-UNAME
                )
             )

             MAPPED DATA(MAPPED_CREATE)
             FAILED DATA(FAILED_CREATE)
             REPORTED DATA(REPORTED_CREATE).

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
         ACT = FAILED_CREATE-PURCHASEREQ
     ).

    DATA(LS_MAPPED) = MAPPED_CREATE-PURCHASEREQ[ 1 ].

    "------------------------------------------------------------
    " Precondition - Header exists in buffer
    "------------------------------------------------------------
    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = 1
        ACT = LINES( LCL_BUFFER=>GT_PR_HEADER )
    ).

    "------------------------------------------------------------
    " Act - Delete before SAVE
    "------------------------------------------------------------
    MODIFY ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
            DELETE FROM VALUE #(
                (
                    PurchaseReqUuid = LS_MAPPED-PurchaseReqUuid
                )
            )
            FAILED DATA(FAILED_DELETE)
            REPORTED DATA(REPORTED_DELETE).

    "------------------------------------------------------------
    " Assert - Delete succeeded
    "------------------------------------------------------------
    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
        ACT = FAILED_DELETE-PURCHASEREQ
    ).

    " CREATE -> DELETE must remove the transaction completely
    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
        ACT = LCL_BUFFER=>GT_PR_HEADER
        MSG = 'CREATE -> DELETE should remove Header from buffer'
    ).

    "------------------------------------------------------------
    " Assert - READ must no longer return Header
    "------------------------------------------------------------
    READ ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
            FIELDS (
                PurchaseReqUuid
                Description
                Status
            )
            WITH VALUE #(
                (
                    PurchaseReqUuid = LS_MAPPED-PurchaseReqUuid
                )
            )
            RESULT DATA(READ_RESULT)
            FAILED DATA(FAILED_READ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
        ACT = READ_RESULT
        MSG = 'Deleted Header must not be visible in transactional READ'
    ).

    "------------------------------------------------------------
    " Assert - Database still untouched
    "------------------------------------------------------------
    SELECT SINGLE PURCHASE_REQ_UUID
        FROM ZEMSt_PR_HDR
        WHERE PURCHASE_REQ_UUID = @LS_MAPPED-PurchaseReqUuid
        INTO @DATA(LV_DB_UUID).


    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
        ACT = LV_DB_UUID
        MSG = 'CREATE -> DELETE must not reach persistence'
    ).


  ENDMETHOD.

  METHOD DELETE_PERSISTED_HEADER.

    "------------------------------------------------------------
    " Arrange - Create persisted test fixture
    "------------------------------------------------------------
    DATA LV_UUID TYPE SYSUUID_X16.
    DATA LV_TIMESTAMP TYPE TIMESTAMPL.

    GET TIME STAMP FIELD LV_TIMESTAMP.

    TRY.

        LV_UUID = CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC(  ).

      CATCH CX_UUID_ERROR.

        CL_ABAP_UNIT_ASSERT=>FAIL(
            MSG = 'Could not generate UUID for persisted test fixture'
        ).

    ENDTRY.

    DATA LT_PERSISTED_HEADER TYPE STANDARD TABLE OF ZEMST_PR_HDR
        WITH EMPTY KEY.

    LT_PERSISTED_HEADER = VALUE #(
        (
            CLIENT = SY-MANDT
            PURCHASE_REQ_UUID = LV_UUID
            PURCHASE_REQ_NO = ''
            DESCRIPTION = 'Persisted Delete Test'
            STATUS = 'C'
            COMPANY_CODE = 'C001'
            Plant = 'P001'
            REQUESTED_BY = SY-UNAME
            CREATED_BY = SY-UNAME
            CREATED_AT = LV_TIMESTAMP
            LAST_CHANGED_BY = SY-UNAME
            LAST_CHANGED_AT = LV_TIMESTAMP
            LOCAL_LAST_CHANGED_AT = LV_TIMESTAMP
        )
    ).

    GO_CDS_ENVIRONMENT->INSERT_TEST_DATA(
        I_DATA = LT_PERSISTED_HEADER
     ).

    SELECT SINGLE PURCHASE_REQ_UUID
       FROM ZEMST_PR_HDR
       WHERE PURCHASE_REQ_UUID = @LV_UUID
       INTO @DATA(LV_FIXTURE_UUID).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = LV_UUID
        ACT = LV_FIXTURE_UUID
        MSG = 'Persisted test fixture was not inserted into CDS test double'
     ).

    "------------------------------------------------------------
    " Act
    "------------------------------------------------------------
    MODIFY ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
            DELETE FROM VALUE #(
                (
                    PurchaseReqUuid = LV_UUID
                )
             )
            FAILED DATA(FAILED_DELETE)
            REPORTED DATA(REPORTED_DELETE).

    "------------------------------------------------------------
    " Assert - RAP operation succeeded
    "------------------------------------------------------------
    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
        ACT = FAILED_DELETE-PURCHASEREQ
     ).

    "------------------------------------------------------------
    " Assert - Header is now marked DELETE in buffer
    "------------------------------------------------------------
    DATA(LS_BUFFER) = LCL_BUFFER=>GT_PR_HEADER[
        CLIENT = SY-MANDT
        PURCHASE_REQ_UUID = LV_UUID
    ].

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = LCL_BUFFER=>GC_DELETE
        ACT = LS_BUFFER-OPERATION
        MSG = 'Persisted Header must be marked for DELETE'
     ).

    "------------------------------------------------------------
    " Assert - Transactional READ must hide deleted Header
    "------------------------------------------------------------
    READ ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
            FIELDS (
                PurchaseReqUuid
                Description
                Status
             )
            WITH VALUE #(
                (
                    PurchaseReqUuid = LV_UUID
                 )
             )
            RESULT DATA(READ_RESULT)
            FAILED DATA(FAILED_READ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
        ACT = READ_RESULT
        MSG = 'Deleted Header must not be visible during transactional READ'
     ).

    "------------------------------------------------------------
    " Assert - Persistence has NOT been deleted yet
    "------------------------------------------------------------
    SELECT SINGLE PURCHASE_REQ_UUID
        FROM ZEMST_PR_HDR
        WHERE PURCHASE_REQ_UUID = @LV_UUID
        INTO @DATA(LV_PERSISTED_UUID).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = LV_UUID
        ACT = LV_PERSISTED_UUID
        MSG = 'Database row must remain until RAP save phase'
     ).

  ENDMETHOD.

  METHOD UPDATE_PERSISTED_HEADER.

    "------------------------------------------------------------
    " Arrange - Persisted Header fixture
    "------------------------------------------------------------
    DATA LV_UUID TYPE SYSUUID_X16.
    DATA LV_TIMESTAMP TYPE TIMESTAMPL.

    GET TIME STAMP FIELD LV_TIMESTAMP.

    TRY.

        LV_UUID = CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC(  ).

      CATCH CX_UUID_ERROR.

        CL_ABAP_UNIT_ASSERT=>FAIL(
            MSG = 'Could not generate UUID for persisted test fixture'
         ).

    ENDTRY.

    DATA LT_PERSISTED_HEADER TYPE STANDARD TABLE OF ZEMST_PR_HDR
        WITH EMPTY KEY.

    LT_PERSISTED_HEADER = VALUE #(
        (
            CLIENT = SY-MANDT
            PURCHASE_REQ_UUID = LV_UUID
            PURCHASE_REQ_NO = ''
            DESCRIPTION = 'Original Persisted Description'
            STATUS = 'C'
            COMPANY_CODE = 'C001'
            Plant = 'P001'
            REQUESTED_BY = SY-UNAME
            CREATED_BY = SY-UNAME
            CREATED_AT = LV_TIMESTAMP
            LAST_CHANGED_BY = SY-UNAME
            LAST_CHANGED_AT = LV_TIMESTAMP
            LOCAL_LAST_CHANGED_AT = LV_TIMESTAMP
        )
     ).

    GO_CDS_ENVIRONMENT->INSERT_TEST_DATA(
       I_DATA = LT_PERSISTED_HEADER
     ).

    "------------------------------------------------------------
    " Precondition - persisted state exists
    "------------------------------------------------------------
    SELECT SINGLE DESCRIPTION
        FROM ZEMST_PR_HDR
        WHERE PURCHASE_REQ_UUID = @LV_UUID
        INTO @DATA(LV_ORIGINAL_DESCRIPTION).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = 'Original Persisted Description'
        ACT = LV_ORIGINAL_DESCRIPTION
    ).

    "------------------------------------------------------------
    " Act - Update only Description
    "------------------------------------------------------------
    MODIFY ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
            UPDATE FIELDS (
                DESCRIPTION
             )
             WITH VALUE #(
                (
                    purchaseReqUuid = LV_UUID
                DESCRIPTION = 'Updated Persisted Description'
                )
              )
              FAILED DATA(FAILED_UPDATE)
              REPORTED DATA(REPORTED_UPDATE).

    "------------------------------------------------------------
    " Assert - RAP operation succeeded
    "------------------------------------------------------------
    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
        ACT = FAILED_UPDATE-PURCHASEREQ
     ).

    "------------------------------------------------------------
    " Assert - latest transactional state is buffered
    "------------------------------------------------------------
    DATA(LS_BUFFER) = LCL_BUFFER=>GT_PR_HEADER[
        CLIENT = SY-MANDT
        PURCHASE_REQ_UUID = LV_UUID
     ].

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
       EXP = LCL_BUFFER=>GC_UPDATE
       ACT = LS_BUFFER-OPERATION
       MSG = 'Persisted Header must become UPDATE in buffer'
     ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
      EXP = 'Updated Persisted Description'
      ACT = LS_BUFFER-DESCRIPTION
     ).

    " Unchanged fields must survive partial UPDATE
    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
       EXP = 'C001'
       ACT = LS_BUFFER-COMPANY_CODE
     ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
       EXP = 'P001'
       ACT = LS_BUFFER-PLANT
    ).

    "------------------------------------------------------------
    " Assert - transactional READ returns updated version
    "------------------------------------------------------------
    READ ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
            FIELDS (
                PurchaseReqUuid
                Description
                Status
                CompanyCode
                Plant
             )
             WITH VALUE #(
                (
                    PurchaseReqUuid = LV_UUID
                )
              )
              RESULT DATA(READ_RESULT)
              FAILED DATA(FAILED_READ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
      ACT = FAILED_READ-PURCHASEREQ
     ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
       EXP = 1
       ACT = LINES( READ_RESULT )
     ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
      EXP = 'Updated Persisted Description'
      ACT = READ_RESULT[ 1 ]-Description
     ).

    "------------------------------------------------------------
    " Assert - persistence still contains old state before SAVE
    "------------------------------------------------------------
    SELECT SINGLE DESCRIPTION
        FROM ZEMST_PR_HDR
        WHERE PURCHASE_REQ_UUID = @LV_UUID
        INTO @DATA(LV_DB_DESCRIPTION).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = 'Original Persisted Description'
        ACT = LV_DB_DESCRIPTION
        MSG = 'UPDATE must not reach persistence before RAP save phase'
     ).

  ENDMETHOD.

  METHOD SAVE_CREATED_HEADER.

    "------------------------------------------------------------
    " Arrange / Act - Create
    "------------------------------------------------------------
    MODIFY ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
            CREATE FIELDS (
                Description
                CompanyCode
                PLANT
                RequestedBy
             )
             WITH VALUE #(
                (
                    %CID = 'PR001'
                    Description = 'Save Create Test'
                    CompanyCode = 'C001'
                    Plant = 'P001'
                    RequestedBy = SY-UNAME
                )
             )
             MAPPED DATA(MAPPED_CREATE)
             FAILED DATA(FAILED_CREATE)
             REPORTED DATA(REPORTED_CREATE).

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
       ACT = FAILED_CREATE-PURCHASEREQ
     ).

    DATA(LS_MAPPED) = MAPPED_CREATE-PURCHASEREQ[ 1 ].

    "------------------------------------------------------------
    " Precondition - Not persisted yet
    "------------------------------------------------------------
    SELECT SINGLE PURCHASE_REQ_UUID
        FROM ZEMST_PR_HDR
        WHERE PURCHASE_REQ_UUID = @LS_MAPPED-PurchaseReqUuid
        INTO @DATA(LV_BEFORE_SAVE).

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
        ACT = LV_BEFORE_SAVE
        MSG = 'Header must not exist before COMMIT ENTITIES'
     ).

    "------------------------------------------------------------
    " Act - RAP Save Sequence
    "------------------------------------------------------------
    COMMIT ENTITIES.

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
        ACT = LCL_BUFFER=>GT_PR_HEADER
        MSG = 'Transactional buffer must be cleared after SAVE'
    ).

    "------------------------------------------------------------
    " Assert - Header was persisted
    "------------------------------------------------------------
    SELECT SINGLE *
        FROM ZEMST_PR_HDR
        WHERE PURCHASE_REQ_UUID = @LS_MAPPED-PurchaseReqUuid
        INTO @DATA(LS_PERSISTED).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = LS_MAPPED-PurchaseReqUuid
        ACT = LS_PERSISTED-PURCHASE_REQ_UUID
    ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
       EXP = 'Save Create Test'
       ACT = LS_PERSISTED-DESCRIPTION
    ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
      EXP = 'C'
      ACT = LS_PERSISTED-STATUS
    ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = 'C001'
        ACT = LS_PERSISTED-COMPANY_CODE
    ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = 'P001'
        ACT = LS_PERSISTED-PLANT
    ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
        ACT = LS_PERSISTED-PURCHASE_REQ_NO
        MSG = 'Business number must still be empty before submit'
    ).


  ENDMETHOD.

  METHOD SAVE_UPDATED_HEADER.

    DATA LV_UUID TYPE SYSUUID_X16.
    DATA LV_TIMESTAMP TYPE TIMESTAMPL.

    GET TIME STAMP FIELD LV_TIMESTAMP.

    TRY.

        LV_UUID = CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC(  ).

      CATCH CX_UUID_ERROR.

        CL_ABAP_UNIT_ASSERT=>FAIL(
            MSG = 'Could not generate UUID for persisted test fixture'
        ).

    ENDTRY.

    DATA LT_PERSISTED_HEADER TYPE STANDARD TABLE OF ZEMST_PR_HDR
        WITH EMPTY KEY.

    LT_PERSISTED_HEADER = VALUE #(
        (
            CLIENT = SY-MANDT
            PURCHASE_REQ_UUID = LV_UUID
            PURCHASE_REQ_NO = ''
            DESCRIPTION = 'Original Save Update test'
            STATUS = 'C'
            COMPANY_CODE = 'C001'
            Plant = 'P001'
            REQUESTED_BY = SY-UNAME
            CREATED_BY = SY-UNAME
            CREATED_AT = LV_TIMESTAMP
            LAST_CHANGED_BY = SY-UNAME
            LAST_CHANGED_AT = LV_TIMESTAMP
            LOCAL_LAST_CHANGED_AT = LV_TIMESTAMP
        )
    ).

    GO_CDS_ENVIRONMENT->INSERT_TEST_DATA(
        I_DATA = LT_PERSISTED_HEADER
    ).

    "------------------------------------------------------------
    " Act - UPDATE during interaction phase
    "------------------------------------------------------------
    MODIFY ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
            UPDATE FIELDS (
                Description
            )
            WITH VALUE #(
                (
                    PurchaseReqUuid = LV_UUID
                    Description = 'Updated After Save'
                )
            )
            FAILED DATA(FAILED_UPDATE)
            REPORTED DATA(REPORTED_UPDATE).

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
       ACT = FAILED_UPDATE-PURCHASEREQ
    ).

    "------------------------------------------------------------
    " Precondition - persistence must still contain old value
    "------------------------------------------------------------
    SELECT SINGLE DESCRIPTION
        FROM ZEMST_PR_HDR
        WHERE PURCHASE_REQ_UUID = @LV_UUID
        INTO @DATA(LV_BEFORE_SAVE).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = 'Original Save Update test'
        ACT = LV_BEFORE_SAVE
    ).

    "------------------------------------------------------------
    " Act - Save Sequence
    "------------------------------------------------------------
    COMMIT ENTITIES.

    "------------------------------------------------------------
    " Assert - persisted state was updated
    "------------------------------------------------------------
    SELECT SINGLE DESCRIPTION
        FROM ZEMST_PR_HDR
        WHERE PURCHASE_REQ_UUID = @LV_UUID
        INTO @DATA(LV_AFTER_SAVE).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = 'Updated After Save'
        ACT = LV_AFTER_SAVE
    ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
        ACT = LCL_BUFFER=>GT_PR_HEADER
        MSG = 'Transactional buffer must be cleared after SAVE'
    ).
  ENDMETHOD.

  METHOD SAVE_DELETED_HEADER.

    DATA LV_UUID TYPE SYSUUID_X16.
    DATA LV_TIMESTAMP TYPE TIMESTAMPL.

    GET TIME STAMP FIELD LV_TIMESTAMP.

    TRY.

        LV_UUID = CL_SYSTEM_UUID=>CREATE_UUID_X16_STATIC(  ).

      CATCH CX_UUID_ERROR.

        CL_ABAP_UNIT_ASSERT=>FAIL(
            MSG = 'Could not generate UUID for persisted test fixture'
        ).

    ENDTRY.

    DATA LT_PERSISTED_HEADER TYPE STANDARD TABLE OF ZEMST_PR_HDR
        WITH EMPTY KEY.

    LT_PERSISTED_HEADER = VALUE #(
        (
            CLIENT = SY-MANDT
            PURCHASE_REQ_UUID = LV_UUID
            PURCHASE_REQ_NO = ''
            DESCRIPTION = 'Original Save Delete test'
            STATUS = 'C'
            COMPANY_CODE = 'C001'
            Plant = 'P001'
            REQUESTED_BY = SY-UNAME
            CREATED_BY = SY-UNAME
            CREATED_AT = LV_TIMESTAMP
            LAST_CHANGED_BY = SY-UNAME
            LAST_CHANGED_AT = LV_TIMESTAMP
            LOCAL_LAST_CHANGED_AT = LV_TIMESTAMP
        )
    ).

    GO_CDS_ENVIRONMENT->INSERT_TEST_DATA(
        I_DATA = LT_PERSISTED_HEADER
    ).

    "------------------------------------------------------------
    " Act - DELETE during interaction phase
    "------------------------------------------------------------
    MODIFY ENTITIES OF ZEMSI_PR_HDR
        ENTITY PurchaseReq
            DELETE FROM VALUE #(
                (
                    PurchaseReqUuid = LV_UUID
                )
            )
            FAILED DATA(FAILED_DELETE)
            REPORTED DATA(REPORTED_DELETE).

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
       ACT = FAILED_DELETE-PURCHASEREQ
    ).

    "------------------------------------------------------------
    " Precondition - persistence must still exists
    "------------------------------------------------------------
    SELECT SINGLE PURCHASE_REQ_UUID
       FROM ZEMST_PR_HDR
       WHERE PURCHASE_REQ_UUID = @LV_UUID
       INTO @DATA(LV_BEFORE_SAVE).

    CL_ABAP_UNIT_ASSERT=>ASSERT_EQUALS(
        EXP = LV_UUID
        ACT = LV_BEFORE_SAVE
    ).

    "------------------------------------------------------------
    " Act - Save Sequence
    "------------------------------------------------------------
    COMMIT ENTITIES.

    "------------------------------------------------------------
    " Assert - persisted state was deleted
    "------------------------------------------------------------
    SELECT SINGLE PURCHASE_REQ_UUID
        FROM ZEMST_PR_HDR
        WHERE PURCHASE_REQ_UUID = @LV_UUID
        INTO @DATA(LV_AFTER_SAVE).

    cl_abap_unit_assert=>ASSERT_INITIAL(
        act = LV_AFTER_SAVE
        msg = 'Persisted Header was not deleted during SAVE'
    ).

    CL_ABAP_UNIT_ASSERT=>ASSERT_INITIAL(
        act = LCL_BUFFER=>GT_PR_HEADER
        msg = 'Transactional buffer must be cleared after SAVE'
    ).

  ENDMETHOD.

ENDCLASS.