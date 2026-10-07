# ZEMSD_PR_DESC – Purchase Requisition Description

## Object Type

DDIC Domain

## Technical Name

`ZEMSD_PR_DESC`

## Purpose

Defines the technical characteristics of the Purchase Requisition
Header description field.

The domain was introduced to provide an EMS-specific semantic type with
sufficient length for business descriptions.

---

## Technical Definition

| Property | Value |
|---|---|
| Data Type | `CHAR` |
| Length | `80` |
| Output Length | `80` |
| Case Sensitive | No |
| Conversion Routine | None |
| Value Definition | No fixed values |

---

## Business Meaning

The domain represents a short descriptive text for a Purchase
Requisition Header.

Example values may include:

```text
Purchase of development laptops
Office equipment procurement
Network infrastructure materials

The domain does not define fixed values because the description is
free-form business text.

## Design Rationale

The Purchase Requisition Header originally reused the standard SAP
data element:

```text
SSTRING

During ABAP Unit testing, a longer Purchase Requisition description was
truncated.

Example:

    |   Expected:
    |   EMS Test Purchase Requisition

    |   Actual:
    |   EMS Test Purchase Re

The issue revealed that the reused semantic type did not provide the
required field length for the EMS Purchase Requisition description.

The persistence model was therefore changed to use an EMS-specific
domain with a length of 80 characters.

This preserves the principle that standard SAP semantics should only be
reused when their technical and business meaning matches the EMS
requirement.

## Usage

The domain is referenced by data element:

```text
ZEMSE_PR_DESC

which is used by:

```text
ZEMST_PR_HDR-DESCRIPTION

and exposed through the Purchase Requisition Header CDS interface as:

```text
Description

## Related Objects

- ZEMSE_PR_DESC – Purchase Requisition Description Data Element
- ZEMST_PR_HDR – Purchase Requisition Header Persistence Table
- ZEMSI_PR_HDR – Purchase Requisition Header CDS Interface

## Related Architecture Decisions
- ADR-005 – Standard SAP Object Reuse
- ADR-010 – RAP Implementation Strategy

## Testing Evidence

The need for this domain was identified through automated ABAP Unit
testing.

The original test was intentionally kept unchanged after correcting the
DDIC model.

The same test passed once the description field used the new
EMS-specific semantic type.

This provides regression protection for the Purchase Requisition
description length requirement.