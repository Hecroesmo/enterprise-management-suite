# ADR-004 – Enhancement Strategy

## Status

Accepted

## Context

ABAP Dictionary tables can define an enhancement category that determines how their structures may be extended.

The main EMS persistence tables are owned and controlled by the EMS project itself.

Allowing arbitrary structural enhancement would make the persistence model harder to govern and could introduce unexpected dependencies.

## Decision

The main EMS persistence tables will initially use:

@AbapCatalog.enhancementCategory: #NOT_EXTENSIBLE

The persistence model will evolve through controlled changes to the EMS source code and architecture.

## Alternatives Considered

### Deep extensibility

Allows complex structural extensions.

Advantages:

- Maximum structural flexibility.

Disadvantages:

- Greater risk of uncontrolled changes.
- Not currently required by the EMS persistence model.

### Character-type extensibility

Allows more limited extensions.

Advantages:

- Provides controlled extension capability.

Disadvantages:

- Still introduces extension points that are not currently required.

### Not extensible

Advantages:

- Strong control over persistence structure.
- Predictable data model.
- Architectural changes remain explicit.

## Rationale

EMS currently owns the full data model and does not require external append structures.

Extensibility should be introduced intentionally when a real requirement appears rather than enabled preemptively.

## Consequences

### Positive

- Controlled schema evolution.
- Reduced risk of unexpected structural extensions.
- Easier reasoning about persistence.

### Negative / Trade-offs

- Future extension requirements may require an architectural change.
- External consumers cannot arbitrarily append fields to the tables.

## Related Decisions

- ADR-001 – Data Model Strategy
- ADR-005 – Standard Object Reuse
