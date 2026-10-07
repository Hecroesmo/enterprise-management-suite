# Purchase Requisition Business Object

## Overview

The EMS Purchase Requisition is modeled as a RAP aggregate consisting of
a Header root entity and lifecycle-dependent Item entities.

```mermaid
flowchart TB
    HDR["ZEMSI_PR_HDR<br/>Purchase Requisition Header<br/><b>Aggregate Root</b>"]

    ITEM["ZEMSI_PR_ITEM<br/>Purchase Requisition Item<br/><b>Lifecycle-dependent Child</b>"]

    HDR -->|"composition [0..*]"| ITEM
    ITEM -->|"association to parent"| HDR
```

## Persistence Model

```mermaid
flowchart TB
    CDS_HDR["ZEMSI_PR_HDR<br/>Root CDS Entity"]
    CDS_ITEM["ZEMSI_PR_ITEM<br/>Child CDS Entity"]

    DB_HDR["ZEMST_PR_HDR<br/>Header Persistence"]
    DB_ITEM["ZEMST_PR_ITEM<br/>Item Persistence"]

    CDS_HDR --> DB_HDR
    CDS_ITEM --> DB_ITEM

    CDS_HDR -->|"composition [0..*]"| CDS_ITEM
    DB_ITEM -->|"purchase_req_uuid"| DB_HDR
```

## Identity Strategy

The aggregate uses technical UUIDs independently from human-readable
business identifiers.

### Header

- `PurchaseReqUuid` — technical identity
- `PurchaseReqNo` — business identifier

### Item

- `PurchaseReqItemUuid` — technical identity
- `PurchaseReqUuid` — parent technical identity
- `ItemNo` — business position inside the Purchase Requisition

Technical UUIDs are assigned early during the RAP interaction phase.

The Purchase Requisition business number is assigned later when the
document reaches the Submit stage.

See:

- ADR-002 – Primary Key Strategy
- ADR-008 – Header–Item Relationship
- ADR-009 – Composition Cardinality
- ADR-012 – Numbering Timing Strategy