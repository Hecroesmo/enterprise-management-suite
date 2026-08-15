# Sprint 1 – Persistence & Semantic Data Model

**Project:** Enterprise Management Suite (EMS)
**Module:** Materials Management – Purchase Requisition
**Sprint:** 1
**Status:** Completed
**Primary Platform:** SAP S/4HANA 1909 On-Premise
**ABAP Platform:** 1909
**SAP_BASIS:** 7.54 SP03
**Development Environment:** ABAP Development Tools (ADT)

---

# 1. Sprint Goal

The goal of Sprint 1 was to transform the conceptual Purchase Requisition model defined during Sprint 0 into an activated SAP persistence and CDS data model.

The sprint focused on:

* Project package creation
* Technical key strategy
* Business key strategy
* Persistence modeling
* SAP standard object reuse
* Status modeling
* Header–Item aggregate modeling
* CDS Composition
* Platform compatibility validation

The sprint intentionally stopped before implementing transactional RAP behavior.

---

# 2. Sprint Scope

The following technical areas were included:

```text
Project Setup
     ↓
Persistence Design
     ↓
Dictionary Objects
     ↓
CDS Interface Model
     ↓
Business Object Structure
```

The following areas were explicitly deferred:

* RAP Behavior Definition
* RAP Behavior Implementation
* Transactional buffer
* Save sequence
* Actions
* Authorization
* Projection layer
* Service exposure
* SAP Fiori Elements UI

---

# 3. Project Package Creation

The following SAP packages were created:

```text
ZEMS
└── ZEMS_MM
```

### `ZEMS`

Root package representing the Enterprise Management Suite.

### `ZEMS_MM`

Functional package containing Materials Management development objects.

Additional EMS packages will only be created when their corresponding modules enter active development.

---

# 4. Technical Key Strategy

A major architectural decision concerned Purchase Requisition identity.

The following strategy was selected:

```text
Technical Identity
        ↓
UUID

Business Identity
        ↓
Human-readable Number Range
```

For the Header:

```text
PurchaseRequisitionUUID
PurchaseRequisitionNumber
```

For the Item:

```text
PurchaseRequisitionItemUUID
ItemNumber
```

UUIDs provide stable and globally unique technical identifiers.

Business numbers provide readable identifiers for:

* Users
* Support
* Printed documents
* Operational communication
* Legacy integration
* Business references

The two responsibilities remain intentionally separated.

Related decision:

```text
ADR-002 – Primary Key Strategy
```

---

# 5. Business vs Technical Responsibility

Two fields were intentionally modeled independently:

```text
REQUESTED_BY
CREATED_BY
```

`REQUESTED_BY` represents the business requester.

`CREATED_BY` represents the technical user or process responsible for persistence.

Example:

```text
CREATED_BY   = INTEGRATION_USER
REQUESTED_BY = BUSINESS_USER
```

This supports scenarios such as:

* External integrations
* Background processing
* Data migrations
* Delegated request creation

Technical audit fields must not automatically be interpreted as business responsibility.

Related decision:

```text
ADR-006 – Business vs Technical Fields
```

---

# 6. Standard Before Custom

The project adopted the principle of reusing SAP standard Dictionary semantics whenever they correctly represent the business requirement.

Examples used include:

```text
BUKRS
WERKS_D
MATNR
MEINS
WAERS
SYUNAME
BNFPO
```

Custom objects are introduced only when EMS has its own semantic requirement.

Related decision:

```text
ADR-005 – Standard Object Reuse
```

---

# 7. Purchase Requisition Header Persistence

The following transparent table was created and activated:

```text
ZEMST_PR_HDR
```

Primary technical key:

```text
CLIENT
PURCHASE_REQ_UUID
```

Main business fields:

```text
PURCHASE_REQ_NO
DESCRIPTION
COMPANY_CODE
PLANT
STATUS
REQUESTED_BY
```

Administrative fields:

```text
CREATED_BY
CREATED_AT
LAST_CHANGED_BY
LAST_CHANGED_AT
LOCAL_LAST_CHANGED_AT
```

The UUID is the stable technical identifier for the Purchase Requisition.

---

# 8. Purchase Requisition Item Persistence

The following transparent table was created and activated:

```text
ZEMST_PR_ITEM
```

Primary technical key:

```text
CLIENT
PURCHASE_REQ_ITEM_UUID
```

Parent reference:

```text
PURCHASE_REQ_UUID
```

Business item identifier:

```text
ITEM_NO
```

Main business fields:

```text
SHORT_TEXT
MATERIAL
QUANTITY
UNIT
NET_PRICE
CURRENCY
```

Administrative fields include:

```text
CREATED_BY
CREATED_AT
LAST_CHANGED_BY
LOCAL_LAST_CHANGED_AT
```

The Material field is optional to support free-text procurement scenarios.

---

# 9. Item Number Strategy

Although every item has a UUID, a readable item number is also retained.

Example:

```text
PR-2026-000101 / Item 00010
PR-2026-000101 / Item 00020
PR-2026-000101 / Item 00030
```

The UUID represents technical identity.

The item number represents business identity within the Purchase Requisition.

Item numbers are not globally unique.

---

# 10. Enhancement Strategy

The main persistence tables use:

```abap
@AbapCatalog.enhancementCategory : #NOT_EXTENSIBLE
```

The EMS persistence model is expected to evolve through controlled project development rather than arbitrary append structures.

Related decision:

```text
ADR-004 – Enhancement Strategy
```

---

# 11. Purchase Requisition Status Model

A custom status Domain and Data Element were created.

Domain:

```text
ZEMSD_PR_STATUS
```

Data Element:

```text
ZEMSE_PR_STATUS
```

Current values:

| Code | Status    |
| ---- | --------- |
| `C`  | Created   |
| `S`  | Submitted |
| `A`  | Approved  |
| `R`  | Rejected  |
| `X`  | Cancelled |

The Domain defines valid values.

The future RAP Behavior will define valid transitions between those values.

For example:

```text
Created → Submitted       Valid
Submitted → Approved      Valid
Submitted → Rejected      Valid

Approved → Created        Invalid
Cancelled → Submitted     Invalid
```

Related decision:

```text
ADR-007 – Status Strategy
```

---

# 12. Draft vs Business Status

Draft was deliberately not modeled as a Purchase Requisition business status.

Conceptually:

```text
Draft
→ Technical editing state
```

while:

```text
Created
Submitted
Approved
Rejected
Cancelled
→ Business states
```

This keeps technical transaction state separate from business lifecycle state.

---

# 13. Header–Item Relationship

Purchase Requisition was modeled as a single aggregate.

```text
Purchase Requisition Header
            │
            │
            ▼
Purchase Requisition Items
```

The Header is the Aggregate Root.

Items are dependent entities whose lifecycle belongs to the Header.

An Item must not logically exist without its parent Purchase Requisition.

Related decision:

```text
ADR-008 – Header–Item Relationship
```

---

# 14. CDS Interface Layer

Two CDS interface definitions were created and activated:

```text
ZEMSI_PR_HDR
ZEMSI_PR_ITEM
```

The Header CDS represents the root entity.

The Item CDS represents the child entity.

---

# 15. CDS Composition

The Header defines:

```abap
composition [0..*] of ZEMSI_PR_ITEM as _Item
```

The Item defines the corresponding parent association.

Conceptually:

```text
ZEMSI_PR_HDR
      │
      │ Composition [0..*]
      ▼
ZEMSI_PR_ITEM
      │
      │ Association to Parent
      └──────────────────► ZEMSI_PR_HDR
```

Composition was selected instead of a normal Association because Header and Items share the same business lifecycle.

---

# 16. Composition Cardinality

The cardinality selected was:

```text
[0..*]
```

instead of:

```text
[1..*]
```

A newly created Purchase Requisition may temporarily contain zero items while the user is entering the document.

However, the following business rule was established:

### BR-PR-001

> A Purchase Requisition must contain at least one item before it can be submitted.

Therefore:

```text
Structural Model
Header → Items = 0..N
```

while:

```text
Business Behavior
Submit requires Items >= 1
```

Related decision:

```text
ADR-009 – Composition Cardinality
```

---

# 17. Timestamp Strategy

The Header contains:

```text
LAST_CHANGED_AT
LOCAL_LAST_CHANGED_AT
```

These fields serve different concurrency and change-tracking responsibilities.

`LOCAL_LAST_CHANGED_AT` represents the last change to the specific entity instance and is intended for optimistic concurrency control.

`LAST_CHANGED_AT` represents the broader last-change information associated with the aggregate.

Detailed ETag behavior will be implemented and validated during the RAP Behavior sprint.

---

# 18. Semantic Annotations

Quantity and amount fields were modeled together with their corresponding semantic reference fields.

Example:

```abap
@Semantics.quantity.unitOfMeasure: 'Unit'
Quantity

Unit
```

and:

```abap
@Semantics.amount.currencyCode: 'Currency'
NetPrice

Currency
```

Semantic annotations are explicitly maintained in the CDS interface model so that the CDS entities are not unnecessarily dependent on annotation propagation from persistence tables.

---

# 19. Platform Compatibility Discovery

During Sprint 1, the actual SAP software component levels were reviewed.

The environment was confirmed as:

```text
SAP S/4HANA 1909 On-Premise
ABAP Platform 1909
SAP_BASIS 7.54 SP03
S4CORE 104 SP03
```

This changed an important initial assumption.

The original project concept anticipated a modern Managed RAP implementation.

After validating the available platform capabilities, the EMS Purchase Requisition Business Object was redesigned to use:

> **Unmanaged RAP**

The semantic data layer also uses the CDS syntax supported by ABAP Platform 7.54.

This was treated as an architectural evolution rather than hiding the original assumption.

Related decision:

```text
ADR-010 – RAP Implementation Strategy
```

---

# 20. Target Unmanaged RAP Architecture

The resulting architecture is:

```text
Persistence Tables
        │
        ▼
DDIC-Based CDS Interface Model
        │
        ▼
Unmanaged Behavior Definition
        │
        ▼
Unmanaged Behavior Implementation
        │
        ▼
Projection Layer
        │
        ▼
Service Definition / Binding
        │
        ▼
OData / SAP Fiori Elements
```

Unmanaged RAP will require explicit implementation of capabilities including:

* Create
* Read
* Update
* Delete
* Transactional buffering
* Persistence logic
* UUID generation
* Business number assignment
* Validations
* Messages
* Key mapping
* Save sequence
* Concurrency handling
* Locking

---

# 21. Architecture Decisions Produced or Consolidated

The sprint produced or consolidated the following decisions:

| ADR     | Decision                     |
| ------- | ---------------------------- |
| ADR-001 | Data Model Strategy          |
| ADR-002 | Primary Key Strategy         |
| ADR-003 | Package Strategy             |
| ADR-004 | Enhancement Strategy         |
| ADR-005 | Standard Object Reuse        |
| ADR-006 | Business vs Technical Fields |
| ADR-007 | Status Strategy              |
| ADR-008 | Header–Item Relationship     |
| ADR-009 | Composition Cardinality      |
| ADR-010 | RAP Implementation Strategy  |

---

# 22. Repository and Documentation Improvements

During the sprint, the GitHub repository was reorganized into a professional documentation and source structure.

Current high-level organization:

```text
enterprise-management-suite/
│
├── README.md
├── LICENSE
├── NOTICE
│
├── docs/
│   ├── general/
│   ├── sprints/
│   └── adr/
│
├── src/
│   └── mm/
│       └── purchase-requisition/
│           ├── dictionary/
│           ├── cds/
│           ├── behavior/
│           ├── services/
│           └── tests/
│
├── architecture/
├── diagrams/
└── screenshots/
```

The project adopted Markdown as the primary documentation format to avoid maintaining duplicate `.docx` and `.md` documentation.

---

# 23. Sprint Deliverables

The following SAP objects were delivered:

```text
ZEMS
ZEMS_MM

ZEMSD_PR_STATUS
ZEMSE_PR_STATUS

ZEMST_PR_HDR
ZEMST_PR_ITEM

ZEMSI_PR_HDR
ZEMSI_PR_ITEM
```

Additional deliverables:

* Technical key strategy
* Business key strategy
* Status model
* Aggregate design
* Composition design
* Business Rule BR-PR-001
* Architecture Decision Records
* Professional Git repository structure
* General project documentation
* Professional project README
* Apache License 2.0 adoption

---

# 24. Definition of Done

Sprint 1 was considered complete when:

* [x] Root project package was created.
* [x] Materials Management package was created.
* [x] Purchase Requisition Header persistence was created.
* [x] Purchase Requisition Item persistence was created.
* [x] UUID technical keys were defined.
* [x] Business identifiers were separated from technical identifiers.
* [x] Purchase Requisition status Domain was created.
* [x] Purchase Requisition status Data Element was created.
* [x] Header and Item tables were activated.
* [x] Header CDS interface definition was created.
* [x] Item CDS interface definition was created.
* [x] Composition was implemented.
* [x] Association to Parent was implemented.
* [x] CDS definitions were activated.
* [x] Platform compatibility was validated.
* [x] Unmanaged RAP was selected for the transactional implementation.
* [x] Architecture decisions were documented.
* [x] Repository documentation was updated.
* [x] No confidential company information was committed.

---

# 25. Sprint Retrospective

## What Went Well

Architecture Reviews before implementation exposed several important design questions early.

Separating technical identity from business identity produced a more robust persistence model.

Reusing SAP standard Dictionary semantics reduced unnecessary custom development.

Composition produced a clear aggregate boundary between Header and Items.

The target SAP platform was investigated before implementation reached the Behavior layer, preventing an incompatible Managed RAP design from progressing further.

## Challenges

The target SAP release introduced limitations compared with newer RAP environments.

Several initial assumptions had to be revised after confirming the actual platform capabilities.

The project documentation initially lagged behind technical implementation and required a dedicated documentation checkpoint.

## What Changed During the Sprint

The largest architectural change was:

```text
Originally Expected
Managed RAP

        ↓ platform validation

Final Decision
Unmanaged RAP
```

This increased implementation complexity but also increased the educational and architectural value of the project.

## Lessons Learned

Platform version matters significantly in SAP architecture.

The terms "S/4HANA" and "RAP support" are not sufficient by themselves; actual component and ABAP Platform versions must be validated.

Architecture documentation should evolve with implementation rather than being postponed until the end.

A technically valid relationship does not automatically represent a business lifecycle relationship. Composition was selected because the business semantics required lifecycle dependency.

---

# 26. Known Technical Debt / Deferred Work

The following areas intentionally remain incomplete:

* Unmanaged RAP Behavior Definition
* Behavior Implementation
* Transactional buffer
* Save sequence
* CRUD logic
* UUID runtime generation
* Purchase Requisition Number Range
* Item numbering logic
* Status transition validations
* Submit action
* Approve action
* Reject action
* Cancel action
* Authorization
* Projection layer
* Service layer
* OData exposure
* SAP Fiori Elements UI
* Automated tests

These are not considered Sprint 1 defects because they belong to subsequent sprint scope.

---

# 27. Sprint Outcome

Sprint 1 successfully converted the Purchase Requisition from an architectural concept into an activated persistence and semantic data model.

The Business Object now has:

```text
Physical Persistence
        +
Semantic CDS Model
        +
Aggregate Structure
        +
Lifecycle Relationship
```

The project is therefore ready for transactional behavior implementation.

---

# 28. Next Sprint

## Sprint 2 – Unmanaged RAP Business Object

Primary objectives:

* Create the Unmanaged Behavior Definition.
* Define supported operations.
* Create the Behavior Pool.
* Design the transactional buffer.
* Implement read operations.
* Implement create processing.
* Generate UUIDs.
* Implement update processing.
* Implement delete processing.
* Implement save sequence.
* Implement `FAILED` and `REPORTED` handling.
* Introduce business validations.
* Prepare the foundation for business actions.

Sprint 2 will represent the transition from a semantic data model to a fully transactional RAP Business Object.

