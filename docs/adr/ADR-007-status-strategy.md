# ADR-007 – Purchase Requisition Status Strategy

## Status

Accepted

## Context

Purchase Requisitions require a controlled business lifecycle.

The application must distinguish between:

1. Valid status values.
2. Valid transitions between status values.

These responsibilities should not be implemented as the same mechanism.

## Decision

EMS will represent Purchase Requisition business statuses through:

Domain:

ZEMSD_PR_STATUS

Data Element:

ZEMSE_PR_STATUS

Initial status values:

| Code | Status |
|---|---|
| C | Created |
| S | Submitted |
| A | Approved |
| R | Rejected |
| X | Cancelled |

The Domain defines the allowed status values.

The RAP Behavior layer will control valid state transitions.

Examples:

Created → Submitted — Allowed

Submitted → Approved — Allowed

Submitted → Rejected — Allowed

Approved → Created — Not Allowed

Cancelled → Submitted — Not Allowed

## Alternatives Considered

### Store complete status names

Example:

SUBMITTED

APPROVED

Advantages:

- Direct readability in the database.

Disadvantages:

- Larger persisted values.
- Business representation becomes coupled to language and textual naming.

### Configuration table for statuses

Advantages:

- Highly configurable.

Disadvantages:

- Allows runtime changes to values that are tightly coupled to application behavior.
- Adds unnecessary complexity for the current lifecycle.

### Domain with fixed values

Advantages:

- Controlled set of stable values.
- Simple persistence.
- Central semantic definition.

## Rationale

The current statuses represent application states rather than freely configurable business master data.

Changing or introducing a status may require corresponding Behavior logic, actions, authorization rules, tests, and UI changes.

Therefore, status evolution should occur through controlled application development.

## Draft Consideration

`Draft` is not modeled as a business status.

Draft represents a technical editing state, while the values maintained in `ZEMSD_PR_STATUS` represent business lifecycle states.

## Consequences

### Positive

- Stable and controlled business lifecycle.
- Clear separation between value validation and transition validation.
- Compact persistence representation.

### Negative / Trade-offs

- Adding a new status requires development and transport.
- Status changes may require updates across several application layers.

## Related Decisions

- ADR-005 – Standard SAP Object Reuse
- ADR-006 – Business vs Technical Fields
- ADR-009 – Composition Cardinality
- ADR-010 – RAP Implementation Strategy
