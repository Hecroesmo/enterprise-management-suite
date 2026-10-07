# ZEMSE_PR_DESC – Purchase Requisition Description

## Object Type

DDIC Data Element

## Technical Name

`ZEMSE_PR_DESC`

## Purpose

Provides the semantic definition and user-facing labels for the
Purchase Requisition Header description field.

The data element references domain:

`ZEMSD_PR_DESC`

which defines the technical type and maximum field length.

---

## Technical Definition

| Property | Value |
|---|---|
| Category | Domain |
| Domain | `ZEMSD_PR_DESC` |
| Data Type | `CHAR` |
| Length | `80` |

The technical characteristics are inherited from the referenced domain.

---

## Field Labels

| Label Type | Text | Maximum Length |
|---|---|---:|
| Short | `PR Desc.` | 10 |
| Medium | `PR Description` | 20 |
| Long | `Purchase Requisition Description` | 40 |
| Heading | `Purchase Requisition Description` | 55 |

The field labels provide the semantic presentation used by SAP
metadata-driven consumers such as user interfaces and reports.

The label lengths do not change the underlying field length.

The description value remains:

```text
CHAR 80

## Business Semantics

The data element represents a short business description of a Purchase
Requisition Header.

Example values may include:

    |   Purchase of development laptops
    |   Office equipment procurement
    |   Network infrastructure materials

The description is free-form business text and does not use fixed
domain values.

## Usage

The data element is currently used by:

```text
ZEMST_PR_HDR-DESCRIPTION

and is exposed through the Purchase Requisition Header CDS interface as:

```text
Description

## Related Objects
- ZEMSD_PR_DESC – Purchase Requisition Description Domain
- ZEMST_PR_HDR – Purchase Requisition Header Persistence Table
- ZEMSI_PR_HDR – Purchase Requisition Header CDS Interface

## Design Background

The data element was introduced after automated testing exposed a field
length limitation in the original description type.

The previous semantic type truncated longer Purchase Requisition
descriptions.

The EMS model was therefore changed to use an explicit Purchase

Requisition description semantic type based on an 80-character domain.

This keeps the DDIC model aligned with the actual business requirement.

## Related Architecture Decisions
- ADR-005 – Standard SAP Object Reuse
- ADR-010 – RAP Implementation Strategy

## Testing Evidence

The need for this data element was identified through ABAP Unit testing.

The original test case used the description:

```text
EMS Test Purchase Requisition

The test initially failed because the value was truncated.
After introducing:

    |   ZEMSD_PR_DESC
            ↓
    |   ZEMSE_PR_DESC

and updating the Header persistence model, the same test passed without
changing the expected business value.

This provides regression protection for the Purchase Requisition
description length requirement.