# ADR-002 – Primary Key Strategy

## Status

Accepted

## Context

Purchase Requisitions require identifiers that satisfy both technical and business requirements.

A human-readable sequential identifier is useful for users, support teams, printed documents, and operational communication.

However, enterprise applications may also participate in integrations, distributed processing, data synchronization, and future system-to-system communication.

Using the same identifier for both technical persistence and business communication would unnecessarily couple these responsibilities.

## Decision

EMS will separate technical identity from business identity.

### Technical Key

Purchase Requisition Header:

`PurchaseRequisitionUUID`

Purchase Requisition Item:

`PurchaseRequisitionItemUUID`

UUIDs will be used as the stable technical identifiers of the entities.

### Business Identifier

Purchase Requisitions will also receive a human-readable business number.

Example:

`PR-2026-000123`

Items will use business item numbers such as:

`00010`

`00020`

`00030`

Therefore, a business reference can be represented as:

`PR-2026-000123 / Item 00010`

## Alternatives Considered

### Number Range as primary technical key

Advantages:

- Compact.
- Human-readable.
- Naturally sequential.

Disadvantages:

- Couples technical identity to business numbering.
- Less suitable for distributed scenarios.
- Requires centralized number generation.
- Business numbering changes could affect technical references.

### Semantic Key as primary key

Advantages:

- Human-readable.
- Business meaning embedded directly in the key.

Disadvantages:

- Business attributes may change.
- Creates stronger coupling between persistence and business semantics.
- More difficult to evolve safely.

### UUID as the only identifier

Advantages:

- Globally unique.
- Simple technical identity strategy.

Disadvantages:

- Poor usability for human communication.
- Inconvenient for support and printed documents.

## Rationale

Technical identity and business identity solve different problems.

UUIDs provide stable and globally unique technical identifiers suitable for integrations and application internals.

Business numbers provide readable references suitable for users and operational processes.

Separating both concerns allows each numbering strategy to evolve independently.

## Consequences

### Positive

- Stable technical identity.
- Improved integration readiness.
- Human-readable business references remain available.
- Business numbering can evolve without changing technical relationships.
- Reduced risk of key collision across systems.

### Negative / Trade-offs

- Two identifiers must be maintained.
- UUIDs consume more storage than short sequential numeric keys.
- Business number generation requires additional logic.

## Related Decisions

- ADR-001 – Data Model Strategy
- ADR-006 – Business vs Technical Fields
- ADR-010 – RAP Implementation Strategy
