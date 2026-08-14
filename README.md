# Enterprise Management Suite (EMS)

**Enterprise Management Suite (EMS)** is a portfolio-driven enterprise application built on **SAP S/4HANA and ABAP RESTful Application Programming Model (RAP)**.

The project simulates the design and implementation of a real-world SAP solution, covering not only development but also architecture, business rules, technical decisions, documentation, testing, and service exposure.

The main goal is to demonstrate practical experience with modern ABAP development and the architectural principles required to build maintainable enterprise applications.

> **Project Status:** Work in Progress
> **Current Module:** Materials Management – Purchase Requisition
> **RAP Scenario:** Unmanaged RAP
> **Target Platform:** SAP S/4HANA 1909 On-Premise / ABAP Platform 1909

---

## Project Goals

EMS was created to consolidate practical knowledge in:

* ABAP RESTful Application Programming Model (RAP)
* ABAP Objects
* Core Data Services (CDS)
* Business Object modeling
* OData services
* SAP Fiori Elements
* Clean Core principles
* Enterprise architecture
* SAP integration patterns
* Transactional processing
* Authorization concepts
* Testing and maintainability

Rather than implementing isolated examples, EMS is designed as an evolving **enterprise solution composed of multiple business modules sharing common architectural standards**.

---

## Architecture

The application follows a layered architecture:

```text
┌──────────────────────────────────────┐
│          SAP Fiori Elements          │
│               UI Layer               │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│       Service Definition/Binding     │
│             Service Layer            │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│      RAP Behavior Implementation     │
│        Business Logic Layer          │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│           CDS Data Model             │
│          Data Access Layer           │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│         Persistence Tables           │
│          SAP HANA Database           │
└──────────────────────────────────────┘
```

Because the current development environment is based on **SAP S/4HANA 1909 / ABAP Platform 1909**, the transactional Business Object is implemented using **Unmanaged RAP** and DDIC-based CDS views.

This requires explicit implementation of several mechanisms that are abstracted by newer managed RAP scenarios, including transactional handling, persistence logic, key generation, validations, messages, and save processing.

---

## Planned Modules

```text
Enterprise Management Suite
│
├── Foundation
│   ├── Authorization
│   ├── Notifications
│   ├── Attachments
│   ├── Audit
│   └── Common Components
│
├── Materials Management
│   ├── Purchase Requisition
│   ├── Purchase Order
│   └── Vendor Management
│
├── Finance
│   ├── Expense Management
│   ├── Invoice Management
│   └── Payment Processing
│
├── Sales
│   ├── Customer Management
│   └── Sales Orders
│
├── Human Capital Management
│   ├── Leave Management
│   ├── Overtime
│   └── Employee Onboarding
│
└── Analytics
```

Modules will be introduced incrementally as the platform evolves.

---

# Current Implementation

## Materials Management – Purchase Requisition

The first EMS Business Object implements a Purchase Requisition process.

### Business Capabilities

The planned lifecycle is:

```text
Created
    │
    ▼
Submitted
   /   \
  ▼     ▼
Approved Rejected

Created / Submitted
        │
        ▼
    Cancelled
```

A Purchase Requisition may contain multiple items and is modeled as an aggregate:

```text
Purchase Requisition Header
            │
            │ Composition [0..*]
            ▼
Purchase Requisition Item
```

The Header acts as the **Aggregate Root**, while Items are lifecycle-dependent child entities.

A Purchase Requisition can temporarily exist without items during creation, but it must contain at least one item before submission.

---

## Current Persistence Model

### Header

SAP object:

```text
ZEMST_PR_HDR
```

Main attributes include:

* Technical UUID
* Business Purchase Requisition Number
* Description
* Status
* Company Code
* Plant
* Requester
* Created By
* Created At
* Last Changed By
* Last Changed At
* Local Last Changed At

### Item

SAP object:

```text
ZEMST_PR_ITEM
```

Main attributes include:

* Technical Item UUID
* Parent Purchase Requisition UUID
* Business Item Number
* Material
* Short Text
* Quantity
* Unit of Measure
* Net Price
* Currency
* Administrative fields

---

## Technical Key Strategy

EMS separates **technical identity** from **business identity**.

Example:

```text
Technical Key
PurchaseRequisitionUUID

Business Identifier
REQ101
```

And for individual items:

```text
Technical Key
PurchaseRequisitionItemUUID

Business Identifier
REQ101 / Item 00010
```

UUIDs provide globally unique technical identifiers suitable for integrations and distributed applications.

Human-readable numbers remain available for business communication, documents, support, and operational processes.

---

## Status Model

Purchase Requisition statuses are represented by:

```text
ZEMSD_PR_STATUS
       │
       ▼
ZEMSE_PR_STATUS
```

Current business statuses:

| Code | Status    |
| ---- | --------- |
| C    | Created   |
| S    | Submitted |
| A    | Approved  |
| R    | Rejected  |
| X    | Cancelled |

Valid values are controlled by the domain, while **valid state transitions are controlled by the RAP Business Object**.

For example:

```text
Created   → Submitted     Valid
Submitted → Approved      Valid
Submitted → Rejected      Valid
Approved  → Created       Invalid
Cancelled → Submitted     Invalid
```

---

# RAP Data Model

The current CDS Business Object structure is:

```text
ZEMSI_PR_HDR
     │
     │ Composition [0..*]
     ▼
ZEMSI_PR_ITEM
     │
     │ Association to Parent
     └──────────────────────► ZEMSI_PR_HDR
```

Implemented interface CDS definitions:

```text
ZEMSI_PR_HDR
ZEMSI_PR_ITEM
```

The next development phase introduces the **Unmanaged RAP Behavior Definition and Behavior Implementation**.

---

# Technology Stack

| Technology         | Usage                          |
| ------------------ | ------------------------------ |
| SAP S/4HANA 1909   | Application Platform           |
| ABAP Platform 1909 | ABAP Runtime                   |
| SAP_BASIS 7.54     | Platform Foundation            |
| SAP HANA           | Persistence                    |
| ABAP               | Application Development        |
| ABAP Objects       | Business Logic                 |
| ABAP RAP           | Transactional Business Objects |
| ABAP CDS           | Semantic Data Model            |
| OData              | Service Exposure               |
| SAP Fiori Elements | Planned UI                     |
| ADT / Eclipse      | Development Environment        |
| Git / GitHub       | Versioning and Documentation   |

---

# Development Principles

## Clean Core

Standard SAP objects are reused whenever their semantics match the business requirement.

Examples include:

```text
BUKRS
WERKS_D
MATNR
MEINS
WAERS
SYUNAME
BNFPO
```

Custom objects are introduced only when the EMS requires its own business semantics.

---

## Technical and Business Fields

Technical audit information is kept separate from business responsibility.

For example:

```text
CREATED_BY
```

represents the user or technical process that persisted the record.

```text
REQUESTED_BY
```

represents the business user requesting the purchase.

This allows scenarios such as:

```text
CREATED_BY   = INTEGRATION_USER
REQUESTED_BY = BUSINESS_USER
```

without mixing technical identity with business responsibility.

---

## Aggregate-Oriented Design

Purchase Requisition Header and Items are treated as one transactional aggregate.

Items cannot logically exist independently from their parent Purchase Requisition.

This relationship is expressed using CDS Composition and will be enforced by the RAP Business Object.

---

# Architecture Decision Records

Important technical decisions are documented using **Architecture Decision Records (ADRs)**.

Current ADRs include:

| ADR     | Decision                     | Status   |
| ------- | ---------------------------- | -------- |
| ADR-001 | Data Model Strategy          | Accepted |
| ADR-002 | Primary Key Strategy         | Accepted |
| ADR-003 | Package Strategy             | Accepted |
| ADR-004 | Enhancement Strategy         | Accepted |
| ADR-005 | Standard Object Reuse        | Accepted |
| ADR-006 | Business vs Technical Fields | Accepted |
| ADR-007 | Status Strategy              | Accepted |
| ADR-008 | Header–Item Relationship     | Accepted |
| ADR-009 | Composition Cardinality      | Accepted |
| ADR-010 | RAP Implementation Strategy  | Accepted |

Architecture decisions can be found under:

```text
docs/adr/
```

---

# Repository Structure

```text
enterprise-management-suite/
│
├── README.md
├── LICENSE
├── .gitignore
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
│           │   ├── domains/
│           │   ├── data-elements/
│           │   └── tables/
│           │
│           ├── cds/
│           │   ├── interface/
│           │   └── projection/
│           │
│           ├── behavior/
│           ├── services/
│           └── tests/
│
├── architecture/
├── diagrams/
└── screenshots/
```

---

# Development Roadmap

## Phase 1 – Foundation

* [x] Define project architecture
* [x] Define package strategy
* [x] Define naming conventions
* [x] Define technical key strategy
* [x] Create Architecture Decision Records
* [x] Create GitHub project structure

## Phase 2 – Purchase Requisition Persistence

* [x] Create Purchase Requisition Header table
* [x] Create Purchase Requisition Item table
* [x] Create Purchase Requisition status domain
* [x] Create Purchase Requisition status data element
* [x] Define UUID technical keys
* [x] Define Header–Item relationship

## Phase 3 – CDS Business Object

* [x] Create Header Interface CDS
* [x] Create Item Interface CDS
* [x] Define Composition
* [x] Define Association to Parent
* [ ] Add additional CDS semantics and annotations

## Phase 4 – Unmanaged RAP

* [ ] Create Behavior Definition
* [ ] Create Behavior Implementation
* [ ] Implement Create
* [ ] Implement Update
* [ ] Implement Delete
* [ ] Implement Read
* [ ] Implement transactional buffer
* [ ] Implement UUID generation
* [ ] Implement Number Range assignment
* [ ] Implement validations
* [ ] Implement state transitions
* [ ] Implement RAP messages
* [ ] Implement save sequence
* [ ] Implement concurrency handling

## Phase 5 – Service Layer

* [ ] Create Projection Views
* [ ] Create Projection Behavior
* [ ] Create Service Definition
* [ ] Create Service Binding
* [ ] Expose OData service

## Phase 6 – User Interface

* [ ] Create SAP Fiori Elements application
* [ ] Configure List Report
* [ ] Configure Object Page
* [ ] Configure value helps
* [ ] Configure actions
* [ ] Configure status presentation

## Phase 7 – Enterprise Capabilities

* [ ] Authorization
* [ ] Approval workflow
* [ ] Attachments
* [ ] Audit history
* [ ] Integration APIs
* [ ] Automated tests
* [ ] Analytics

---

# Business Rules

Business rules are documented independently from the physical data model.

Example:

### BR-PR-001

> A Purchase Requisition must contain at least one item before it can be submitted.

This allows the technical CDS cardinality to remain:

```text
[0..*]
```

while the RAP Business Object enforces:

```text
Submission requires >= 1 item
```

This separation keeps structural constraints independent from process rules.

---

# Project Methodology

EMS is developed incrementally using sprint-based delivery.

Each development cycle follows:

```text
Business Requirement
        │
        ▼
Architecture Review
        │
        ▼
Technical Design
        │
        ▼
Implementation
        │
        ▼
Testing
        │
        ▼
Code Review
        │
        ▼
Documentation
```

Significant design choices go through an Architecture Review and may result in a new ADR.

---

# Why Unmanaged RAP?

The development environment currently uses:

```text
SAP S/4HANA 1909 On-Premise
ABAP Platform 1909
SAP_BASIS 7.54
```

The implementation therefore uses the RAP capabilities available on that release, including **Unmanaged RAP**.

Although this requires more explicit implementation work, it provides an opportunity to understand important RAP internals such as:

* Transaction handling
* Business Object buffers
* Key mapping
* Persistence
* Save sequencing
* Failed and reported structures
* Business validations
* Concurrency
* Lock handling

The architecture can later be compared with a Managed RAP implementation on a newer ABAP Platform.

---

# Future Evolution

The project is intended to evolve beyond the initial Purchase Requisition scenario.

Future iterations may introduce:

* SAP standard API integration
* Purchase Order creation
* Event-driven integration
* SAP Integration Suite
* SAP BTP
* SAP Event Mesh
* SAP Build Process Automation
* Additional S/4HANA business domains
* A Managed RAP implementation for architectural comparison

---

# Documentation

Detailed project documentation is maintained under:

```text
docs/
```

Including:

* General project documentation
* Sprint documentation
* Architecture Decision Records
* Technical decisions
* Business rules

Architecture diagrams and screenshots are maintained separately to keep the repository easy to navigate.

---

# Disclaimer

This project is a **generic educational and professional portfolio project**.

It does not contain:

* proprietary company source code;
* production data;
* internal system credentials;
* private endpoints;
* confidential configuration;
* customer information.

All business scenarios, source code, documentation, and examples published in this repository are intended to remain generic and independent from any specific organization.

---

# Author

**Hecroesmo Wambano**

SAP ABAP Developer focused on modern SAP development, ABAP Cloud, RAP, integrations, and Clean Core architecture.

SAP Certified – Back-End Developer – ABAP Cloud.

---

# License

See the repository `LICENSE` file for licensing information.

