# ADR-011 – Transactional Buffer Strategy

## Status

Accepted

## Context

The EMS Purchase Requisition Business Object is implemented using
Unmanaged RAP.

During the RAP interaction phase, the same entity may receive multiple
operations before the Logical Unit of Work reaches the save phase.

Examples include:

CREATE → UPDATE

UPDATE → UPDATE

CREATE → DELETE

UPDATE → DELETE

Writing directly to persistence from Behavior Handlers would tightly
couple the interaction phase to database persistence and make aggregate
consistency, rollback behavior and sequential modifications more
difficult to manage.

## Decision

EMS will use a single transactional buffer for each Business Object
entity.

Each buffered instance will contain:

- The latest transactional version of the entity data.
- An operation state representing its effective persistence operation.

Initial operation states are:

- `C` – Create
- `U` – Update
- `D` – Delete

Behavior Handlers must not directly persist changes to
`ZEMST_PR_HDR` or `ZEMST_PR_ITEM`.

Persistence will occur during the RAP save phase.

## Operation Consolidation

Multiple operations against the same entity during one Logical Unit of
Work must be consolidated.

Examples:

### CREATE → UPDATE

The entity remains in state `C`.

The buffer contains the latest version of the entity.

### CREATE → DELETE

The buffered entity is removed.

No persistence operation is required.

### UPDATE → UPDATE

The entity remains in state `U`.

The latest data replaces the previous buffered version.

### UPDATE → DELETE

The entity transitions to state `D`.

## Alternatives Considered

### Separate buffers per operation

Examples:

- Create Buffer
- Update Buffer
- Delete Buffer

Advantages:

- Simple representation of individual operations.

Disadvantages:

- READ operations must reconcile multiple buffers.
- Sequential modifications require cross-buffer coordination.
- The current transactional state becomes harder to determine.

### Single state-aware buffer

Advantages:

- Single source of truth for the transaction.
- Easier transactional reads.
- Easier consolidation of sequential operations.
- Simpler save processing.
- Easier aggregate validation.

## Rationale

During the interaction phase, consumers should observe the latest
transactional state rather than only the last persisted database state.

A state-aware buffer provides one consolidated representation of that
state.

## Consequences

### Positive

- Consistent transactional reads.
- Easier handling of sequential operations.
- Clear separation between interaction and persistence phases.
- Simplified Save Sequence.
- Better aggregate-level validation.

### Negative / Trade-offs

- Buffer state transitions must be implemented correctly.
- READ operations must merge persisted and buffered data.
- Buffer lifecycle must be cleaned after transaction completion.

## Related Decisions

- ADR-008 – Header–Item Relationship
- ADR-010 – RAP Implementation Strategy
