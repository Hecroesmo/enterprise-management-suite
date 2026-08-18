# ADR-008 – Purchase Requisition Header–Item Relationship

## Status

Accepted

## Context

A Purchase Requisition consists of general document information and one or more procurement items.

The project must determine whether Header and Item should behave as independent business entities or as parts of the same business aggregate.

A Purchase Requisition Item has no meaningful independent lifecycle without its parent Purchase Requisition.

## Decision

Purchase Requisition Header and Items will be modeled as a single RAP Business Object aggregate.

The Header acts as the Aggregate Root.

The Item acts as a lifecycle-dependent child entity.

The CDS relationship is represented through Composition.

Conceptually:

ZEMSI_PR_HDR
    |
    | Composition
    v
ZEMSI_PR_ITEM

The Item contains the parent technical reference:

purchase_req_uuid

The child CDS also defines an association to its parent Header.

## Alternatives Considered

### Normal CDS Association

Advantages:

- Simple relationship.
- Suitable for entities that can exist independently.

Disadvantages:

- Does not express lifecycle ownership.
- Does not accurately represent the business semantics of Purchase Requisition Items.

### Independent Business Objects

Advantages:

- Maximum technical independence.

Disadvantages:

- Incorrect lifecycle representation.
- Additional transaction coordination required.
- Allows conceptual orphan Items.

### Composition

Advantages:

- Expresses ownership and lifecycle dependency.
- Defines a clear aggregate boundary.
- Aligns with the Purchase Requisition business model.

## Rationale

An Item is an integral part of a Purchase Requisition.

If the parent business document ceases to exist, its Items should not continue as independent business entities.

Composition therefore represents the relationship more accurately than a regular Association.

## Consequences

### Positive

- Clear aggregate boundary.
- Lifecycle relationship explicitly represented.
- Transactional behavior can be designed around one root entity.
- Orphan business Items are conceptually prevented.

### Negative / Trade-offs

- Child lifecycle becomes intentionally coupled to the Header.
- Unmanaged RAP requires lifecycle persistence behavior to be implemented explicitly.

## Related Decisions

- ADR-001 – Data Model Strategy
- ADR-002 – Primary Key Strategy
- ADR-009 – Composition Cardinality
- ADR-010 – RAP Implementation Strategy
