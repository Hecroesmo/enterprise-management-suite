# Enterprise Management Suite (EMS)

## General Project Documentation

**Document Type:** General Project Documentation
**Project:** Enterprise Management Suite (EMS)
**Project Status:** In Development
**Current Release:** Development Version
**Current Module:** Materials Management – Purchase Requisition
**Development Approach:** Incremental / Sprint-Based
**Primary SAP Platform:** SAP S/4HANA 1909 On-Premise
**ABAP Platform:** ABAP Platform 1909 / SAP_BASIS 7.54

---

# 1. Introduction

The **Enterprise Management Suite (EMS)** is a modular enterprise application designed and developed on SAP S/4HANA using modern ABAP development concepts.

The project was created as a real-world implementation initiative to consolidate practical knowledge in:

* ABAP RESTful Application Programming Model (RAP)
* ABAP Objects
* Core Data Services (CDS)
* Enterprise application architecture
* SAP business processes
* Clean Core principles
* API-based integration
* SAP Fiori
* Transactional application development
* Software documentation and technical governance

Unlike isolated training exercises, EMS is designed as a continuously evolving enterprise solution composed of several interconnected business modules.

The project simulates the lifecycle of a professional SAP implementation, including business analysis, architectural decisions, technical design, development, testing, code review, documentation, and service exposure.

---

# 2. Project Vision

The vision of EMS is to create a modular enterprise platform that demonstrates how modern SAP applications can be designed from the ground up using structured architecture and well-defined business domains.

EMS is not intended to replace SAP S/4HANA standard functionality.

Instead, it serves as:

1. A practical SAP development environment.
2. A professional portfolio project.
3. A reference implementation for RAP concepts.
4. A platform for experimenting with enterprise architecture patterns.
5. A foundation for future SAP integration and cloud scenarios.

The long-term objective is to evolve EMS into a reference application containing several enterprise processes implemented using a consistent architectural model.

---

# 3. Project Objectives

The main objectives of EMS are to:

* Apply theoretical SAP knowledge to realistic business scenarios.
* Design complete SAP Business Objects rather than isolated programs.
* Develop practical experience with RAP.
* Understand the internal mechanisms of transactional SAP applications.
* Apply Clean Core principles wherever technically possible.
* Reuse SAP standard semantics and technical objects.
* Separate business logic from technical infrastructure.
* Implement maintainable and extensible software components.
* Practice enterprise-level documentation.
* Apply Architecture Decision Records to significant technical decisions.
* Build reusable patterns that can be applied across multiple modules.
* Create a technical portfolio that demonstrates practical SAP development experience.

---

# 4. Guiding Principles

EMS follows several architectural and development principles.

## 4.1 Business First

Technical implementation decisions should originate from business requirements.

The project should not introduce technical complexity without a clear business or architectural reason.

The preferred decision flow is:

```text
Business Requirement
        ↓
Business Analysis
        ↓
Architecture Review
        ↓
Technical Design
        ↓
Implementation
```

---

## 4.2 Clean Core

EMS follows Clean Core principles whenever they are applicable to the target platform.

This includes:

* Reusing released or standard SAP semantics where appropriate.
* Avoiding unnecessary modifications to SAP standard objects.
* Minimizing technical coupling with SAP internal implementation details.
* Creating custom objects only when a real business requirement justifies them.
* Keeping custom functionality logically separated from SAP standard functionality.

---

## 4.3 Standard Before Custom

SAP standard objects should be reused whenever their business semantics match the EMS requirement.

Examples include:

* `BUKRS` for Company Code
* `WERKS_D` for Plant
* `MATNR` for Material
* `MEINS` for Unit of Measure
* `WAERS` for Currency
* `SYUNAME` for SAP User
* `BNFPO` for Purchase Requisition Item Number

Custom Data Elements and Domains should only be created when EMS introduces its own business semantics.

---

## 4.4 Technical Identity Is Different from Business Identity

Business entities may require two different identifiers.

### Technical Identifier

Used internally by applications, APIs, persistence layers, and integrations.

Example:

```text
PurchaseRequisitionUUID
```

### Business Identifier

Used by people and business processes.

Example:

```text
PR-2026-000123
```

EMS therefore uses UUIDs as technical keys while maintaining readable business identifiers where appropriate.

---

## 4.5 Explicit Business Rules

Business rules should not be hidden inside database structures.

For example, a Purchase Requisition may technically exist without items while it is being prepared.

However:

> A Purchase Requisition cannot be submitted without at least one item.

Therefore:

```text
Structural Cardinality
Header → Items = 0..N
```

while:

```text
Business Rule
Submitted PR → Items >= 1
```

This distinction keeps the data model flexible while preserving business integrity through the application behavior.

---

## 4.6 Aggregate-Oriented Design

Business Objects are modeled as aggregates whenever multiple entities share the same business lifecycle.

For example:

```text
Purchase Requisition
        │
        ├── Header
        │
        └── Items
```

The Purchase Requisition Header acts as the Aggregate Root.

Purchase Requisition Items are lifecycle-dependent children and should not logically exist independently from their parent.

---

# 5. Target Architecture

EMS uses a layered architecture.

```text
┌─────────────────────────────────────┐
│              UI Layer               │
│        SAP Fiori / Fiori Elements   │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│            Service Layer            │
│   Service Definition / OData API    │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│        Business Behavior Layer      │
│       RAP Behavior Implementation   │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│          Semantic Data Layer        │
│               ABAP CDS              │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│          Persistence Layer          │
│       SAP HANA / Custom Tables      │
└─────────────────────────────────────┘
```

Each module should follow the same architectural pattern whenever applicable.

---

# 6. Target SAP Environment

The initial EMS implementation is developed against the following SAP environment:

| Component                         | Version   |
| --------------------------------- | --------- |
| SAP S/4HANA                       | 1909      |
| SAP S/4HANA Support Package Stack | 03        |
| ABAP Platform                     | 1909      |
| SAP_BASIS                         | 7.54 SP03 |
| S4CORE                            | 104 SP03  |
| SAP Fiori for S/4HANA             | 1909      |
| SAP Fiori Front-End Server        | 6.0 SP03  |

Because this platform represents an earlier RAP implementation level, EMS uses the RAP capabilities available for this release.

The first transactional Business Objects are therefore implemented using **Unmanaged RAP**.

This creates an opportunity to explicitly implement and study concepts such as:

* Transactional buffering
* Create processing
* Update processing
* Delete processing
* Read processing
* Key generation
* Persistence handling
* Save sequence
* Business validations
* RAP messages
* Failed and reported entities
* Lock handling
* Concurrency handling

Future versions of EMS may implement equivalent scenarios using Managed RAP on newer ABAP platforms for comparison.

---

# 7. Functional Scope

EMS is planned as a modular enterprise system.

## 7.1 Foundation

Common capabilities shared across modules.

Planned components include:

* Authorization
* Audit logging
* Attachments
* Notifications
* Common value helps
* Reusable business utilities
* Common technical services

## 7.2 Materials Management

Planned capabilities include:

* Purchase Requisition Management
* Purchase Order Management
* Vendor-related processes
* Inventory-related scenarios

The Purchase Requisition Business Object is the first implemented EMS business process.

## 7.3 Finance

Planned capabilities include:

* Expense Management
* Vendor Invoice Management
* Approval processes
* Payment-related scenarios

## 7.4 Sales

Planned capabilities include:

* Customer Management
* Sales Order Management
* Order approval scenarios

## 7.5 Human Capital Management

Planned capabilities include:

* Leave Management
* Overtime Requests
* Employee Onboarding
* Employee Self-Service scenarios

## 7.6 Analytics

Future analytical capabilities may include:

* Operational dashboards
* KPI reporting
* Procurement analytics
* Financial analytics
* Employee-related analytics

---

# 8. Current Implementation – Purchase Requisition

The Purchase Requisition module represents the first complete Business Object implemented in EMS.

Its purpose is to allow users to create and manage internal requests for goods or services.

The initial lifecycle is:

```text
Created
   │
   ▼
Submitted
  /     \
 ▼       ▼
Approved Rejected
```

Cancellation may be permitted depending on the current business state.

## 8.1 Purchase Requisition Aggregate

The Business Object consists of:

```text
Purchase Requisition Header
            │
            │ Composition [0..*]
            ▼
Purchase Requisition Item
```

The Header represents the Aggregate Root.

Items belong to the lifecycle of the Header.

## 8.2 Persistence Objects

Current persistence objects include:

### Header Table

```text
ZEMST_PR_HDR
```

### Item Table

```text
ZEMST_PR_ITEM
```

### Status Domain

```text
ZEMSD_PR_STATUS
```

### Status Data Element

```text
ZEMSE_PR_STATUS
```

## 8.3 CDS Interface Layer

Current CDS interface definitions include:

```text
ZEMSI_PR_HDR
ZEMSI_PR_ITEM
```

The Header defines a composition to its Items.

The Item defines an association to its parent Header.

---

# 9. Purchase Requisition Status Model

The current statuses are:

| Code | Status    |
| ---- | --------- |
| C    | Created   |
| S    | Submitted |
| A    | Approved  |
| R    | Rejected  |
| X    | Cancelled |

The Domain controls the valid status codes.

The Business Object Behavior will control whether a transition between two valid states is permitted.

For example:

```text
Created → Submitted       Allowed
Submitted → Approved      Allowed
Submitted → Rejected      Allowed

Approved → Created        Not Allowed
Cancelled → Submitted     Not Allowed
```

This ensures that value validation and process validation remain separate responsibilities.

---

# 10. Development Methodology

EMS is developed incrementally using sprint-based delivery.

Each sprint follows the lifecycle:

```text
Business Requirement
        ↓
Analysis
        ↓
Architecture Review
        ↓
Technical Design
        ↓
Implementation
        ↓
Testing
        ↓
Code Review
        ↓
Documentation
```

A sprint is considered complete only when its technical implementation and documentation are consistent with each other.

---

# 11. Definition of Done

Depending on the scope of a development item, the Definition of Done may include:

* Business requirement understood.
* Technical design completed.
* Relevant Architecture Review completed.
* Required ADR created or updated.
* Development objects activated successfully.
* Naming standards respected.
* Business rules implemented.
* Error handling implemented.
* Relevant tests executed.
* Code reviewed.
* Documentation updated.
* Repository updated.
* No confidential information committed.

---

# 12. Architecture Governance

Significant architectural decisions are documented using **Architecture Decision Records (ADRs)**.

An ADR should normally contain:

* Context
* Decision
* Alternatives considered
* Rationale
* Positive consequences
* Negative consequences / trade-offs
* Related architectural decisions

Current decisions include topics such as:

* Persistence strategy
* UUID strategy
* Package organization
* Extensibility
* SAP standard object reuse
* Business vs technical fields
* Status management
* Aggregate relationships
* Composition cardinality
* RAP implementation strategy

ADRs are stored under:

```text
docs/adr/
```

---

# 13. Naming Conventions

EMS follows consistent naming conventions for custom SAP development objects.

| Object Type                  | Convention                       | Example           |
| ---------------------------- | -------------------------------- | ----------------- |
| Package                      | `ZEMS_*`                         | `ZEMS_MM`         |
| Transparent Table            | `ZEMST_*`                        | `ZEMST_PR_HDR`    |
| Domain                       | `ZEMSD_*`                        | `ZEMSD_PR_STATUS` |
| Data Element                 | `ZEMSE_*`                        | `ZEMSE_PR_STATUS` |
| Interface CDS                | `ZEMSI_*`                        | `ZEMSI_PR_HDR`    |
| Consumption / Projection CDS | `ZEMSC_*`                        | To be introduced  |
| Class                        | `ZEMSC_*` or project convention  | To be defined     |
| Service                      | `ZEMSUI_*` or project convention | To be defined     |

Naming conventions may evolve through Architecture Reviews when required.

Any change affecting the global naming strategy should be documented.

---

# 14. Repository Structure

The EMS repository is organized by documentation and technical domain.

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
│           ├── cds/
│           ├── behavior/
│           ├── services/
│           └── tests/
│
├── architecture/
├── diagrams/
└── screenshots/
```

The repository structure will evolve as additional EMS modules are introduced.

---

# 15. Source Code and Confidentiality Policy

EMS is intended to remain a generic and publicly shareable project.

The repository must never include confidential or proprietary information from a real organization.

The following information must not be committed:

* Production data
* Employee information
* Customer information
* Internal endpoints
* Internal hostnames
* Credentials
* Passwords
* Certificates
* API secrets
* Company-specific source code
* Proprietary configuration
* Internal business documents
* Confidential screenshots

Examples used in documentation should be generic or synthetic.

---

# 16. Testing Strategy

Testing will be introduced progressively as each application layer becomes available.

## Technical Testing

Validation of individual ABAP components and methods.

## Business Rule Testing

Validation of business rules such as:

* Status transitions
* Mandatory fields
* Minimum item requirements
* Authorization rules

## Business Object Testing

Testing of RAP operations such as:

* Create
* Read
* Update
* Delete
* Actions
* Validations

## API Testing

Testing of exposed services through appropriate API testing tools.

## UI Testing

Validation of SAP Fiori behavior after the presentation layer is introduced.

---

# 17. Integration Strategy

EMS is designed so that integrations can be introduced without tightly coupling the domain model to external systems.

Future integration scenarios may include:

* SAP standard APIs
* REST APIs
* OData services
* BAPIs
* RFC interfaces
* SAP Integration Suite
* Event-driven communication
* SAP Event Mesh

External integration concerns should remain separated from core business logic whenever possible.

---

# 18. Security and Authorization

Authorization will be designed as part of the Business Object rather than as an afterthought.

Authorization decisions may depend on:

* Business role
* Current document state
* Organizational responsibility
* Requested By
* Company Code
* Plant
* Approval responsibility

Technical fields such as `CREATED_BY` should not automatically determine business authorization.

For example:

```text
CREATED_BY
```

may contain an integration or background user.

While:

```text
REQUESTED_BY
```

represents the actual business requester.

---

# 19. Project Roadmap

## Stage 1 – Project Foundation

* Project structure
* Package strategy
* Naming conventions
* Architecture governance
* Git repository
* General documentation

## Stage 2 – Purchase Requisition Persistence

* Header table
* Item table
* Status domain
* Status data element
* Technical key strategy

## Stage 3 – Semantic Data Model

* Header CDS
* Item CDS
* Composition
* Parent association
* Semantic annotations

## Stage 4 – Unmanaged RAP Business Object

* Behavior Definition
* Behavior Implementation
* Create
* Read
* Update
* Delete
* Transactional buffer
* Key generation
* Validations
* Actions
* Messages
* Save sequence

## Stage 5 – Service Layer

* Projection CDS
* Projection Behavior
* Service Definition
* Service Binding
* OData exposure

## Stage 6 – User Interface

* SAP Fiori Elements
* List Report
* Object Page
* Value Helps
* Actions
* Status visualization

## Stage 7 – Enterprise Capabilities

* Authorization
* Approval workflow
* Attachments
* Audit history
* Integration
* Automated testing
* Analytics

## Stage 8 – Additional EMS Modules

* Finance
* Sales
* Human Capital Management
* Inventory
* Common Foundation Services

---

# 20. Future Architecture Evolution

EMS is intentionally designed as an evolving project.

Possible future architecture improvements include:

* Managed RAP implementation on a newer ABAP Platform
* Side-by-side extensions on SAP BTP
* SAP Integration Suite
* Event-driven architecture
* SAP Event Mesh
* SAP Build Process Automation
* Cloud-based APIs
* Automated CI/CD
* abapGit integration
* Additional automated testing
* Observability and application logging
* AI-assisted enterprise scenarios

The implementation should evolve without invalidating the architectural principles established during the initial project phases.

---

# 21. Project Success Criteria

EMS will be considered successful when it demonstrates the ability to:

* Translate business requirements into technical SAP solutions.
* Design transactional Business Objects.
* Implement RAP applications.
* Explain architectural decisions and trade-offs.
* Apply SAP standard semantics correctly.
* Build maintainable ABAP solutions.
* Expose enterprise services.
* Implement SAP Fiori applications.
* Apply authorization and validation rules.
* Integrate SAP with external systems.
* Produce professional technical documentation.
* Demonstrate practical SAP development experience through working software.

---

# 22. Disclaimer

Enterprise Management Suite is a generic educational and professional portfolio project.

It is not an official SAP product and is not affiliated with or endorsed by SAP SE.

SAP, SAP S/4HANA, ABAP, SAP Fiori, SAP HANA, and other SAP products and services referenced in this project are trademarks or registered trademarks of SAP SE or its affiliates.

The project does not represent the internal systems, source code, architecture, configuration, or business processes of any specific organization.

---

# 23. License

Enterprise Management Suite is distributed under the **Apache License 2.0**.

Refer to the repository `LICENSE` file for the complete licensing terms.

---

# 24. Document Maintenance

This document represents the high-level definition of the Enterprise Management Suite.

It should be updated whenever there is a significant change to:

* Project scope
* Architecture
* Technology strategy
* Supported modules
* Development methodology
* Major platform assumptions

Detailed technical decisions should not be documented directly in this file when an Architecture Decision Record is more appropriate.

Sprint-specific implementation details should be maintained under the corresponding Sprint documentation.
