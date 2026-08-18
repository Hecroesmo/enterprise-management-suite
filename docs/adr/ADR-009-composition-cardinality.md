# ADR-009 – Composition Cardinality

## Status

Accepted

## Context

The Purchase Requisition Header is composed of Purchase Requisition Items.

A decision was required between:

composition [0..*]

and:

composition [1..*]

From a business perspective, a submitted Purchase Requisition must contain at least one Item.

However, during document creation, a Header may temporarily exist before the user has added the first Item.

## Decision

The CDS Composition will use:

composition [0..*] of ZEMSI_PR_ITEM as _Item

The requirement for at least one Item will be enforced as a business rule before submission rather than as a structural CDS cardinality requirement.

Business rule:

**BR-PR-001 – A Purchase Requisition must contain at least one Item before it can be submitted.**

Therefore:

Structural model:

Header → Items = 0..N

Business rule at submission:

Header → Items >= 1

## Alternatives Considered

### `[1..*]`

Advantages:

- Expresses that a valid completed Purchase Requisition requires at least one Item.

Disadvantages:

- Does not represent the temporary creation state correctly.
- Mixes business process validation with structural modeling.

### `[0..*]`

Advantages:

- Correctly supports document creation.
- Separates data structure from process rules.
- Allows the Behavior layer to decide when an Item becomes mandatory.

## Rationale

Cardinality describes the structural relationship between entities.

The minimum number of Items required to execute a business action such as Submit is a business rule.

Those concerns should remain separate.

## Consequences

### Positive

- Supports incremental document creation.
- Clean separation between structural and business constraints.
- Business validation can evolve independently from CDS cardinality.

### Negative / Trade-offs

- The application must explicitly validate the minimum Item requirement.
- Persistence can temporarily contain active Purchase Requisitions with no Items depending on the implemented lifecycle rules.

## Related Decisions

- ADR-007 – Purchase Requisition Status Strategy
- ADR-008 – Header–Item Relationship
- ADR-010 – RAP Implementation Strategy
