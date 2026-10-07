# ZEMSE_PR_STATUS – Purchase Requisition Status

## Object Type

DDIC Data Element

## Technical Name

`ZEMSE_PR_STATUS`

## Purpose

Provides the semantic definition and user-facing labels for the
Purchase Requisition business status field.

The data element references domain:

`ZEMSD_PR_STATUS`

which defines the technical type and allowed fixed values.

---

## Technical Definition

| Property | Value |
|---|---|
| Category | Domain |
| Domain | `ZEMSD_PR_STATUS` |
| Data Type | `CHAR` |
| Length | `1` |

The technical attributes are inherited from the referenced domain.

---

## Field Labels

| Label Type | Text | Maximum Length |
|---|---|---:|
| Short | `PR Status` | 10 |
| Medium | `PR Status` | 20 |
| Long | `Purchase Req. Status` | 40 |
| Heading | `PR Status` | 55 |

These labels provide the semantic presentation of the field in SAP
user interfaces, reports and other metadata-driven consumers.

The label lengths do not change the underlying field length.

The persisted status value remains:

```text
CHAR 1

## Business Semantics

The data element represents the current business lifecycle state of a
Purchase Requisition.

Examples include:

    |   C – Created
    |   S – Submitted
    |   A – Approved
    |   R – Rejected
    |   X – Canceled

The allowed values are defined by domain:

```text
ZEMSD_PR_STATUS

Business transition rules between these states are implemented in the
RAP Behavior layer rather than in the data element.

## Usage

The data element is currently used by:

```text
ZEMST_PR_HDR-STATUS

and is exposed through the Purchase Requisition Header CDS interface as:

```text
Status

## Related Objects
- ZEMSD_PR_STATUS – Purchase Requisition Status Domain
- ZEMST_PR_HDR – Purchase Requisition Header Persistence Table
- ZEMSI_PR_HDR – Purchase Requisition Header CDS Interface

## Related Architecture Decisions
- ADR-007 – Purchase Requisition Status Strategy
- ADR-010 – RAP Implementation Strategy

## Notes

The data element provides semantic meaning and UI labels.

It does not control valid business transitions.

For example, both:

    |   Created
    |   Approved

are individually valid domain values, but a direct:

```text
Created → Approved

transition may still be rejected by the RAP Business Object.