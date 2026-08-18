# ADR-003 – Package Strategy

## Status

Accepted

## Context

EMS is intended to evolve into a modular enterprise application containing multiple business domains.

Without a clear package strategy, development objects could become mixed across unrelated functional areas, increasing coupling and making ownership difficult to understand.

## Decision

EMS will use a root package and functional packages organized by business domain.

Initial structure:

ZEMS
└── ZEMS_MM

Planned future structure:

ZEMS
├── ZEMS_COMMON
├── ZEMS_MM
├── ZEMS_FI
├── ZEMS_SD
├── ZEMS_HCM
└── ZEMS_TEST

Only packages required by active development will be created.

## Alternatives Considered

### Single package for all EMS objects

Advantages:

- Simple initial setup.

Disadvantages:

- Poor scalability.
- Weak separation of business domains.
- Difficult navigation as the number of objects increases.

### Technical-layer packages only

Example:

- Tables
- CDS
- Classes
- Services

Advantages:

- Objects grouped by technical type.

Disadvantages:

- Business domain ownership becomes less clear.
- Objects belonging to one business capability are distributed across multiple high-level packages.

### Business-domain-oriented packages

Advantages:

- Clear functional boundaries.
- Better ownership.
- Easier navigation.
- Supports future modular growth.

## Rationale

Business domains provide more stable architectural boundaries than technical object types.

Technical organization can still exist inside each functional domain when necessary.

## Consequences

### Positive

- Clear business ownership.
- Improved maintainability.
- Better scalability as EMS grows.
- Reduced risk of unrelated objects becoming tightly coupled.

### Negative / Trade-offs

- Requires governance when deciding where shared functionality belongs.
- Common functionality may require dedicated shared packages in the future.

## Related Decisions

- ADR-001 – Data Model Strategy
- ADR-005 – Standard Object Reuse
