CLASS lcl_buffer DEFINITION FINAL.

  PUBLIC SECTION.

    CONSTANTS:
      gc_create TYPE c LENGTH 1 VALUE 'C',
      gc_update TYPE c LENGTH 1 VALUE 'U',
      gc_delete TYPE c LENGTH 1 VALUE 'D'.

    TYPES:
      BEGIN OF ty_pr_header,
        operation TYPE c LENGTH 1.
        INCLUDE TYPE zemst_pr_hdr.
    TYPES:
      END OF ty_pr_header.

    TYPES:
      BEGIN OF ty_pr_item,
        operation TYPE c LENGTH 1.
        INCLUDE TYPE zemst_pr_item.
    TYPES:
      END OF ty_pr_item.

    TYPES tt_pr_header TYPE HASHED TABLE OF ty_pr_header
      WITH UNIQUE KEY client purchase_req_uuid.

    TYPES tt_pr_item TYPE HASHED TABLE OF ty_pr_item
      WITH UNIQUE KEY client purchase_req_item_uuid.

    CLASS-DATA:
      gt_pr_header TYPE tt_pr_header,
      gt_pr_item   TYPE tt_pr_item.

    CLASS-METHODS clean_buffer.

ENDCLASS.


CLASS lcl_buffer IMPLEMENTATION.

  METHOD clean_buffer.

    CLEAR:
      gt_pr_header,
      gt_pr_item.

  ENDMETHOD.

ENDCLASS.