# ADR-010 – RAP Implementation Strategy

## Status

Accepted

## Context

The initial EMS architecture assumed that the Purchase Requisition Business Object could be implemented using a modern Managed RAP scenario.

During Sprint 1, the actual target SAP platform was validated.

The development environment is:

- SAP S/4HANA 1909 On-Premise
- ABAP Platform 1909
- SAP_BASIS 7.54 SP03
- S4CORE 104 SP03

The RAP capabilities available on this release differ from those available on newer ABAP platforms.

The implementation strategy therefore had to be adapted to the capabilities of the actual target system.

## Decision

The first EMS Purchase Requisition transactional Business Object will be implemented using **Unmanaged RAP**.

The architecture will follow this general structure:

Persistence Tables
        |
        v
DDIC-Based CDS Interface Model
        |
        v
Unmanaged Behavior Definition
        |
        v
Unmanaged Behavior Implementation
        |
        v
Projection Layer
        |
        v
Service Definition / Binding
        |
        v
OData / SAP Fiori Elements

The project will explicitly implement transactional responsibilities that would otherwise be partially handled by a Managed RAP runtime.

These responsibilities include:

- Create processing
- Read processing
- Update processing
- Delete processing
- Transactional buffering
- Persistence handling
- UUID generation
- Business key assignment
- Key mapping
- Validations
- RAP messages
- FAILED and REPORTED handling
- Save sequence
- Lock handling
- Concurrency handling

## Alternatives Considered

### Managed RAP on the current system

Rejected because the required Managed RAP implementation capabilities are not available at the required level on the target SAP S/4HANA 1909 environment.

### Move development to a newer SAP environment

Advantages:

- Access to newer RAP capabilities.
- Reduced manual transactional implementation.

Disadvantages:

- The currently available development system would no longer be usable as the primary practical environment.
- Removes the opportunity to study lower-level RAP transactional responsibilities.

### Unmanaged RAP on the existing system

Advantages:

- Compatible with the current project environment.
- Provides deeper understanding of RAP internals.
- Allows the project to continue using an available enterprise SAP system.

## Rationale

Architecture must follow verified platform capabilities rather than assumed capabilities.

Using Unmanaged RAP allows EMS to implement a valid transactional Business Object while providing additional practical experience with transaction handling and persistence responsibilities.

The increased implementation complexity is considered beneficial to the learning objectives of the project.

## Consequences

### Positive

- Compatible with the available SAP platform.
- Deeper understanding of RAP transactional architecture.
- Explicit control over persistence.
- Practical experience with transactional buffering and save handling.
- Stronger technical portfolio value.

### Negative / Trade-offs

- More source code is required.
- Higher implementation complexity.
- More responsibility for transactional consistency.
- CRUD, persistence, key handling, and save behavior must be designed carefully.
- Some patterns will differ from newer Managed RAP implementations.

## Future Evolution

A future EMS implementation may reproduce the same Purchase Requisition Business Object using Managed RAP on a newer ABAP Platform.

This would allow a direct architectural comparison between:

Unmanaged RAP

and:

Managed RAP

using the same business domain.

## Related Decisions

- ADR-001 – Data Model Strategy
- ADR-002 – Primary Key Strategy
- ADR-007 – Purchase Requisition Status Strategy
- ADR-008 – Header–Item Relationship
- ADR-009 – Composition Cardinality
