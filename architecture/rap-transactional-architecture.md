# RAP Transactional Architecture

## Overview

The EMS Purchase Requisition Business Object is implemented using
Unmanaged RAP on SAP S/4HANA 1909.

Because persistence is unmanaged, the application explicitly controls
the transactional state of the Business Object during the RAP
interaction phase and persists the resulting state during the RAP save
sequence.

The architecture separates:

- Business Object interaction
- Transactional state management
- Database persistence

This prevents Behavior Handlers from writing directly to persistence
during every individual operation.

---

## High-Level Flow

```text
Consumer / EML / OData
          |
          v
RAP Behavior Definition
          |
          v
Behavior Handler
          |
          v
Transactional Buffer
     C / U / D state
          |
          v
RAP Save Sequence
          |
          v
Persistence Tables
```text

## Business Object

The Purchase Requisition is modeled as an aggregate.

```text
Purchase Requisition Header
        Aggregate Root
             |
             | composition [0..*]
             v
Purchase Requisition Item
     Lifecycle-dependent child
```text

The root entity is represented by:
- ZEMSI_PR_HDR

The child entity is represented by:
- ZEMSI_PR_ITEM

The persistence layer uses:
- ZEMST_PR_HDR
- ZEMST_PR_ITEM

## Interaction Phase

During the interaction phase, RAP operations are handled without
immediately changing persistent database state.

Typical operations include:
- CREATE
- READ
- UPDATE
- DELETE
- Create-by-Association
- Read-by-Association

The latest transactional version of an entity is maintained in memory
until the save sequence is executed.

## Transactional Buffer

EMS uses a single state-aware transactional buffer per entity.

Each buffered instance contains:
- The latest version of the entity data
- An effective persistence operation
The supported operation states are:

| State | Meaning |
|---|---|
| `C` | Entity must be inserted |
| `U` | Persisted entity must be updated |
| `D` | Persisted entity must be deleted |

The buffer represents the net effect of all operations executed during
the current Logical Unit of Work.

## State Consolidation

Sequential operations are consolidated before persistence.

### Create followed by Update
|       CREATE -> UPDATE

Result:

|       C

The entity remains a new entity and will eventually be persisted using
an INSERT.

### Create followed by Delete
|       CREATE -> DELETE

Result:
|       No buffered entity

The operations cancel each other and no database operation is required.

### Persisted Entity followed by Update
|       Persisted -> UPDATE

Result:
|       U

The latest transactional state is retained in the buffer.

### Persisted Entity followed by Delete
|       Persisted -> DELETE

Result:
|       D

The persisted entity is marked for deletion during the save sequence.

## Transactional Read Strategy

READ operations first inspect the transactional buffer.

If the requested entity exists in the buffer, the buffered version has
priority over persistent state because it represents the latest state
of the current Logical Unit of Work.

text```
READ
 |
 v
Buffer contains entity?
 |
 +-- Yes --> Deleted?
 |             |
 |             +-- Yes --> Do not return entity
 |             |
 |             +-- No --> Return buffered state
 |
 +-- No --> Read persistence
 ```text

 This ensures that operations such as:
 |      CREATE -> UPDATE -> READ

 ## Save Sequence

Persistence is executed by the RAP saver.

The transactional buffer is processed and its effective operation is
translated into the corresponding database operation.

text```
|   C -> INSERT
|   U -> UPDATE
|   D -> DELETE
```text

The current implementation processes the buffer using a single loop
with operation-specific persistence logic.

This favors implementation clarity and traceability for the expected
Purchase Requisition transaction volume.

Batch-oriented persistence may be introduced later if performance
requirements justify it without changing the transactional buffer
architecture.

## Buffer Cleanup

After the save sequence completes, the transactional buffer is cleared.

This prevents transactional data from leaking into subsequent Logical
Units of Work handled by the same ABAP session.

Test teardown logic also explicitly resets RAP transactional state and
the custom unmanaged buffer.

## Technical Numbering

Technical UUIDs are generated during the interaction phase.

For a Purchase Requisition Header:

text```
CREATE
  |
  +-- Generate UUID
  +-- Initialize business state
  +-- Populate administrative fields
  +-- Add to transactional buffer
```text

The human-readable Purchase Requisition business number is deliberately
not generated at this stage.

It will be assigned when the document is submitted.

See:
- ADR-002 – Primary Key Strategy
- ADR-012 – Numbering Timing Strategy

## Testing Architecture

The transactional architecture is covered by ABAP Unit tests.

The current test environment uses the CDS Test Double Framework with
double redirection enabled.

This allows both:
|   EML / CDS access

and:
|   Open SQL access to persistence tables

to operate against the same isolated test environment.

Conceptually:

text```
ABAP Unit
     |
     v
CDS Test Environment
     |
     +------------------+
     |                  |
     v                  v
EML / CDS           Open SQL
     |                  |
     +--------+---------+
              |
              v
         Test Doubles
```text

This prevents unit tests from modifying real EMS persistence data.

### Current Header Test Coverage

The Purchase Requisition Header currently has automated coverage for:

- Header creation
- Transactional reads
- Update of newly created instances
- Create followed by Delete
- Delete of persisted instances
- Update of persisted instances
- CREATE persistence during save
- UPDATE persistence during save
- DELETE persistence during save

These tests validate the following transactional matrix:

| Initial State | Operation | Effective Result |
|---|---|---|
| Nonexistent | CREATE | `C` |
| `C` | UPDATE | `C` |
| `C` | DELETE | Removed |
| Persisted | UPDATE | `U` |
| Persisted | DELETE | `D` |

## Current Limitations

The following areas are still under implementation:
- Item Create-by-Association
- Item numbering
- Item transactional operations
- Header-to-Item navigation
- Aggregate persistence
- Business validations
- Business actions
- Locking
- ETag handling
- Authorization
- Business number generation

These capabilities will be introduced incrementally in subsequent EMS
implementation steps.

## Related Architecture Decisions

- ADR-002 – Primary Key Strategy
- ADR-007 – Purchase Requisition Status Strategy
- ADR-008 – Header–Item Relationship
- ADR-009 – Composition Cardinality
- ADR-010 – RAP Implementation Strategy
- ADR-011 – Transactional Buffer Strategy
- ADR-012 – Numbering Timing Strategy