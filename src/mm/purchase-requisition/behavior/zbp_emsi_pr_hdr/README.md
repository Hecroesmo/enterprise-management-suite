# ZBP_EMSI_PR_HDR – Behavior Pool Snapshots

This directory contains sanitized source snapshots extracted from the
local implementation areas of the RAP Behavior Pool:

`ZBP_EMSI_PR_HDR`

The source is split into multiple files for readability and code review.

These files do not represent independent global ABAP classes.

They originate from the local implementation sections of the same
Behavior Pool.

## Structure

### Local Types

| File | ABAP Local Class | Responsibility |
|---|---|---|
| `lcl_buffer.abap` | `LCL_BUFFER` | Transactional Header and Item buffers |
| `lhc_purchase_req.abap` | `LHC_PURCHASEREQ` | Purchase Requisition Header behavior handler |
| `lhc_purchase_req_item.abap` | `LHC_PURCHASEREQITEM` | Purchase Requisition Item behavior handler |
| `lsc_zemsi_pr_hdr.abap` | `LSC_ZEMSI_PR_HDR` | RAP save sequence and cleanup |

### Test Classes

| File | ABAP Local Class | Responsibility |
|---|---|---|
| `ltcl_purchase_req.abap` | `LTCL_PURCHASE_REQ` | ABAP Unit tests for the Purchase Requisition Business Object |

## Important

The split is repository-only.

Inside SAP ADT, these classes belong to the same Behavior Pool class
implementation.