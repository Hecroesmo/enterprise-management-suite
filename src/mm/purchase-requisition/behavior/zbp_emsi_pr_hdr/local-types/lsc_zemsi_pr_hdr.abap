CLASS lsc_ZEMSI_PR_HDR DEFINITION
  INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.
    METHODS finalize          REDEFINITION.
    METHODS save              REDEFINITION.
    METHODS cleanup           REDEFINITION.

ENDCLASS.


CLASS lsc_ZEMSI_PR_HDR IMPLEMENTATION.

  METHOD check_before_save.
  ENDMETHOD.


  METHOD finalize.
  ENDMETHOD.


  METHOD save.

    LOOP AT lcl_buffer=>gt_pr_header INTO DATA(ls_buffer).

      DATA(ls_persistence) =
        CORRESPONDING zemst_pr_hdr( ls_buffer ).

      CASE ls_buffer-operation.

        "------------------------------------------------------------
        " CREATE -> INSERT
        "------------------------------------------------------------
        WHEN lcl_buffer=>gc_create.

          INSERT zemst_pr_hdr
            FROM @ls_persistence.

        "------------------------------------------------------------
        " UPDATE -> UPDATE
        "------------------------------------------------------------
        WHEN lcl_buffer=>gc_update.

          UPDATE zemst_pr_hdr
            FROM @ls_persistence.

        "------------------------------------------------------------
        " DELETE -> DELETE
        "------------------------------------------------------------
        WHEN lcl_buffer=>gc_delete.

          DELETE FROM zemst_pr_hdr
            WHERE purchase_req_uuid =
              @ls_persistence-purchase_req_uuid.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.


  METHOD cleanup.

    lcl_buffer=>clean_buffer( ).

  ENDMETHOD.

ENDCLASS.