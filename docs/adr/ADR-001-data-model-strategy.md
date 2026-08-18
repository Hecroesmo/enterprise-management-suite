# ADR-001 – Data Model Strategy

## Status

Accepted

## Context

The Enterprise Management Suite (EMS) requires a persistence model for the Purchase Requisition Business Object.

Two main approaches were considered:

1. Build the EMS Purchase Requisition directly on SAP standard persistence objects such as `EBAN`.
2. Create dedicated EMS persistence tables and integrate with SAP standard business objects at a later stage.

The primary objective of EMS is to provide a controlled environment for implementing and studying enterprise application architecture, RAP, CDS, business rules, and integration patterns without creating unnecessary dependencies on existing SAP MM configuration.

## Decision

EMS will use dedicated custom persistence tables for the Purchase Requisition Business Object.

The initial tables are:

- `ZEMST_PR_HDR` – Purchase Requisition Header
- `ZEMST_PR_ITEM` – Purchase Requisition Item

The EMS Purchase Requisition will therefore initially operate as an independent business object.

Integration with SAP standard Purchase Requisitions may be introduced in a future development phase through appropriate SAP APIs or other supported integration mechanisms.

## Alternatives Considered

### Direct use of SAP standard persistence

Advantages:

- Immediate alignment with the SAP MM data model.
- Existing SAP business functionality could potentially be reused.

Disadvantages:

- Strong dependency on SAP MM configuration.
- Higher implementation complexity.
- Increased coupling with SAP standard internals.
- Reduced freedom to experiment with the EMS domain model.
- Greater risk when using the project as a public portfolio implementation.

### Dedicated EMS persistence

Advantages:

- Full control over the data model.
- Independent Business Object lifecycle.
- Easier experimentation with RAP patterns.
- Clear separation between custom functionality and SAP standard functionality.
- Future integration can be introduced explicitly.

## Rationale

The purpose of EMS is not to replace SAP MM functionality.

A dedicated persistence model allows the Purchase Requisition scenario to be developed as an independent enterprise application while maintaining the possibility of integrating with SAP standard processes later.

This approach also keeps the project generic and suitable for a public technical portfolio.

## Consequences

### Positive

- Complete control over persistence and lifecycle.
- Reduced coupling with SAP standard internal tables.
- Easier testing and experimentation.
- Clear ownership of the EMS domain model.
- Future SAP integration can be designed explicitly.

### Negative / Trade-offs

- Existing SAP MM Purchase Requisition functionality is not automatically inherited.
- Integration with SAP standard procurement requires additional implementation.
- Some business rules already available in SAP standard functionality must be modeled independently in EMS.

## Related Decisions

- ADR-002 – Primary Key Strategy
- ADR-005 – Standard Object Reuse
- ADR-008 – Header–Item Relationship
- ADR-010 – RAP Implementation Strategy
