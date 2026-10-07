# Sprint 2 – Unmanaged RAP Transactional Foundation

## Status

**In Progress**

The Header transactional lifecycle is complete and covered by automated
tests.

The Item transactional lifecycle, Header–Item association handling and
aggregate persistence are still under implementation.

---

## Sprint Goal

Build the transactional foundation of the EMS Purchase Requisition
Business Object using Unmanaged RAP.

The sprint introduces the mechanisms required to move the Purchase
Requisition from a static CDS data model to a transactional Business
Object capable of handling:

- Create
- Read
- Update
- Delete
- Transactional buffering
- RAP save sequence
- Persistence
- Transaction cleanup
- Automated ABAP Unit testing

The implementation must maintain a clear separation between the RAP
interaction phase and database persistence.

---

## Starting Point

Sprint 2 started after completion of the persistence and semantic data
model delivered in Sprint 1.

The following components were already available:

- Package structure
- Purchase Requisition persistence tables
- Purchase Requisition status domain and data element
- Header and Item CDS interface entities
- Header–Item composition
- Association to parent
- Technical UUID key strategy
- Business identifier strategy
- Unmanaged RAP implementation decision

The Business Object still had no transactional behavior.

---

# 1. Behavior Model

## Minimal Behavior Definition

The first implementation deliberately started with the smallest
Behavior Definition that could compile successfully on the target
platform.

The Header behavior supports:

- Create
- Update
- Delete
- Create Item by association

The Item behavior currently supports:

- Update
- Delete

Technical UUID fields are controlled by the Business Object.

A simplified representation is:

```text
PurchaseReq
├── CREATE
├── UPDATE
├── DELETE
└── _Item
    └── CREATE BY ASSOCIATION

PurchaseReqItem
├── UPDATE
└── DELETE
```

The implementation was introduced incrementally.

Actions, validations, feature control, authorization, ETag handling and
locking were intentionally excluded from the first version.

This reduced implementation complexity and allowed each RAP capability
to be introduced and tested independently.

---

# 2. Behavior Pool

The RAP Behavior Pool is implemented by:

```text
ZBP_EMSI_PR_HDR
```

The generated local classes include:

```text
ZBP_EMSI_PR_HDR
│
├── lhc_PurchaseReq
│   ├── create
│   ├── read
│   ├── update
│   ├── delete
│   ├── cba_ITEM
│   └── rba_ITEM
│
├── lhc_PurchaseReqItem
│   ├── read
│   ├── update
│   └── delete
│
└── lsc_ZEMSI_PR_HDR
    ├── finalize
    ├── check_before_save
    ├── save
    └── cleanup
```

The local handler classes operate during the RAP interaction phase.

The saver class is responsible for persistence during the RAP save
sequence.

---

# 3. Transactional Buffer

## Architecture

EMS uses a single state-aware transactional buffer for each Business
Object entity.

The Header buffer stores:

- The latest transactional version of the Header
- The effective persistence operation

The initial operation states are:

| State | Meaning |
|---|---|
| `C` | Create |
| `U` | Update |
| `D` | Delete |

The buffer acts as the in-memory representation of the current Logical
Unit of Work.

Behavior Handlers do not directly persist changes to the database.

---

## State Consolidation

Multiple operations against the same entity are consolidated before
persistence.

The Header implementation currently supports the following transition
matrix:

| Initial State | Operation | Effective Result |
|---|---|---|
| Not persisted | CREATE | `C` |
| `C` | UPDATE | `C` |
| `C` | DELETE | Removed from buffer |
| Persisted | UPDATE | `U` |
| Persisted | DELETE | `D` |

### CREATE → UPDATE

A newly created Header remains in state `C`.

The latest values replace the previous buffered values, but persistence
still requires an INSERT.

### CREATE → DELETE

The Header is removed from the transactional buffer.

No persistence operation is necessary because the entity did not exist
before the current Logical Unit of Work.

### Persisted → UPDATE

The persisted Header is loaded into the buffer and marked as `U`.

### Persisted → DELETE

The persisted Header is loaded into the buffer and marked as `D`.

---

# 4. Header CREATE

The Header CREATE implementation performs the following operations:

```text
CREATE Request
      ↓
Generate technical UUID
      ↓
Initialize business state
      ↓
Populate administrative fields
      ↓
Store Header in transactional buffer
      ↓
Return %CID → UUID mapping
```

The UUID is generated during the interaction phase.

This implements the early technical numbering strategy defined in
ADR-012.

The following fields are initialized by the Business Object:

- `PurchaseReqUuid`
- `Status`
- `CreatedBy`
- `CreatedAt`
- `LastChangedBy`
- `LastChangedAt`
- `LocalLastChangedAt`

The initial business status is:

```text
C – Created
```

The Purchase Requisition business number remains empty.

It will be generated later when the document is submitted.

---

# 5. Header READ

The Header READ implementation follows a transaction-first strategy.

```text
READ
  ↓
Check Transactional Buffer
  ↓
Found?
├── Yes → return latest transactional state
└── No  → read persistence
```

The buffer has priority over persisted state because it represents the
latest version of the entity inside the current Logical Unit of Work.

Entities marked for deletion are not returned by transactional reads.

This allows scenarios such as:

```text
CREATE
  ↓
UPDATE
  ↓
READ
```

to return the updated in-memory state even before a save occurs.

---

# 6. Header UPDATE

Header UPDATE supports partial entity modifications.

Only fields explicitly marked by RAP `%control` are changed.

For example:

```text
UPDATE
Description = New Description
```

does not overwrite:

- Company Code
- Plant
- Requested By
- Other unchanged business fields

The implementation first searches the transactional buffer.

If the entity is not buffered, its persisted state is loaded and
introduced into the buffer.

---

## Buffered Update Optimization

An implementation issue was discovered during testing.

The original logic used:

```abap
MODIFY TABLE lcl_buffer=>gt_pr_header
  FROM ls_buffer.
```

This worked for:

```text
CREATE → UPDATE
```

because the Header already existed in the buffer.

However, it failed for:

```text
Persisted → UPDATE
```

because `MODIFY TABLE` did not insert a missing row into the hashed
buffer.

The implementation was refactored to work directly with the buffered
row using a field symbol.

Conceptually:

```text
Entity already buffered?
        │
   ┌────┴────┐
  Yes        No
   │          │
ASSIGN     Read DB
   │          │
   │       INSERT + ASSIGN
   └─────┬────┘
         ↓
      <buffer>
         ↓
Modify latest transactional state directly
```

This removed the need for a final `MODIFY TABLE` operation and eliminated
the inconsistent behavior between newly created and persisted entities.

---

# 7. Header DELETE

DELETE behavior depends on the transactional origin of the Header.

## Newly Created Header

```text
CREATE → DELETE
```

The Header is removed completely from the buffer.

The net persistence effect is zero.

## Persisted Header

```text
Persisted → DELETE
```

The persisted entity is loaded into the buffer and marked:

```text
Operation = D
```

The physical database deletion occurs only during the save sequence.

---

# 8. RAP Save Sequence

The saver processes the transactional Header buffer.

The current implementation uses a single loop over the buffer and
dispatches persistence according to the effective operation.

```text
Transactional Buffer
        ↓
       LOOP
        ↓
      CASE
   ┌────┼────┐
   C    U    D
   ↓    ↓    ↓
INSERT UPDATE DELETE
   └────┼────┘
        ↓
   Persistence
```

The current strategy favors:

- Simplicity
- Traceability
- Clear persistence behavior
- Easy debugging

The expected Purchase Requisition transaction volume does not currently
justify additional batching complexity.

Batch persistence may be introduced later without changing the
transactional buffer architecture if performance requirements demand
it.

---

# 9. Buffer Cleanup

The RAP saver implements cleanup behavior after the save sequence.

The custom transactional buffer is cleared after the transaction.

This prevents state from one Logical Unit of Work from leaking into
another request handled by the same ABAP session.

ABAP Unit teardown logic also performs explicit RAP transaction cleanup.

---

# 10. Automated Testing

ABAP Unit tests are implemented directly in the Behavior Pool Test
Classes.

Tests interact with the Business Object through EML instead of directly
calling private handler methods.

This verifies the same transactional contract used by RAP consumers.

---

## Current Test Coverage

The Header currently has nine passing automated tests:

| Test | Purpose |
|---|---|
| `create_header` | Creates a Header and validates UUID, defaults and transactional buffer state |
| `read_created_header` | Reads a Header that exists only in the transactional buffer |
| `update_created_header` | Validates CREATE → UPDATE and partial update behavior |
| `create_delete_header` | Validates CREATE → DELETE cancellation |
| `delete_persisted_header` | Marks an existing persisted Header as `D` |
| `update_persisted_header` | Loads and updates persisted state into the transactional buffer |
| `save_created_header` | Validates `C → INSERT` |
| `save_updated_header` | Validates `U → UPDATE` |
| `save_deleted_header` | Validates `D → DELETE` |

Current result:

```text
9 tests
9 passed
```

---

# 11. Test Double Architecture

Testing persisted scenarios initially used the ABAP SQL Test Double
Framework.

A significant issue was discovered.

The test fixture was visible when accessed directly from the ABAP Unit
test, but persistence access performed through the RAP execution path
could not see the same state.

The initial situation was:

```text
Unit Test SELECT
      ↓
SQL Test Double
      ↓
Fixture visible
```

while:

```text
EML
 ↓
RAP Handler
 ↓
Persistence SELECT
 ↓
Fixture not visible
```

The test architecture was therefore changed to use:

```text
CDS Test Environment
+
Double Redirection
```

The resulting architecture is:

```text
ABAP Unit
     ↓
CDS Test Environment
     ↓
Double Redirection
   ↙                  ↘
EML / CDS          Open SQL
   \                  /
    \                /
       Test Doubles
```

This allows RAP/EML execution and direct persistence access inside the
unmanaged Behavior implementation to operate against the same isolated
test state.

No real EMS persistence data is modified by the tests.

---

# 12. DDIC Issue Discovered by Testing

The original Header Description field reused SAP data element:

```text
SSTRING
```

The first CREATE unit test exposed that the description was truncated:

```text
Expected:
EMS Test Purchase Requisition

Actual:
EMS Test Purchase Re
```

The issue was traced to the DDIC semantic definition rather than the
Behavior implementation.

The data model was corrected by introducing EMS-specific semantics:

```text
ZEMSD_PR_DESC
        ↓
ZEMSE_PR_DESC
```

The field now supports the required Purchase Requisition description
length.

The original test remained unchanged and passed after correcting the
data model.

This validated the value of using automated tests to identify hidden
data-model constraints.

---

# 13. Persistence Mapping Issue

Another issue was discovered while loading persisted entities.

The CDS entity exposes semantic aliases such as:

```text
PurchaseReqUuid
CompanyCode
RequestedBy
```

while the persistence table uses:

```text
purchase_req_uuid
company_code
requested_by
```

Using `MOVE-CORRESPONDING` between a CDS-shaped structure and the
persistence-shaped transactional buffer resulted in incomplete mapping.

The persistence loading logic was therefore aligned directly with:

```text
ZEMST_PR_HDR
```

which matches the transactional buffer representation.

This maintains a clean relationship:

```text
Persistence Representation
          ↓
Transactional Buffer
```

while the CDS entity remains the external RAP business representation.

---

# 14. Key Engineering Lessons

Sprint 2 has reinforced several architectural principles.

## Compile Success Is Not Functional Correctness

Code activation alone did not guarantee correct semantics.

Automated tests detected issues that the ABAP compiler could not
identify.

---

## The Transactional Buffer Is the Current LUW State

Database persistence represents committed state.

The transactional buffer represents the latest state of the current
Logical Unit of Work.

Transactional READ operations must therefore prefer the buffer.

---

## Test Infrastructure Is Part of the Architecture

Choosing between SQL and CDS Test Doubles was not merely a testing
implementation detail.

The selected test environment must intercept the same access paths used
by the production implementation.

---

## Persistence and RAP Representations Are Different Concerns

CDS field aliases provide a clean business representation.

Persistence fields provide a storage representation.

The implementation must respect this boundary rather than assuming that
automatic name-based mapping will always be sufficient.

---

## Tests Should Follow Development Incrementally

The sprint originally grouped testing toward the end.

The implementation evolved toward:

```text
Implement capability
        ↓
Test capability
        ↓
Refactor
        ↓
Continue
```

This approach detected design and implementation issues substantially
earlier.

---

# 15. Architecture Decisions Introduced

Sprint 2 introduced the following Architecture Decision Records:

### ADR-011 – Transactional Buffer Strategy

Defines the use of a single state-aware transactional buffer and the
effective operation model:

```text
C / U / D
```

### ADR-012 – Numbering Timing Strategy

Defines:

- Early technical UUID generation
- Deferred Purchase Requisition business number assignment

Technical identity exists during the interaction phase.

Business identity is assigned when the Purchase Requisition becomes
officially relevant.

---

# 16. Completed Work

## Behavior Model

- [x] Create minimal Unmanaged Behavior Definition
- [x] Add Header behavior
- [x] Add Item behavior
- [x] Define Header CRUD contract
- [x] Define Create-by-Association contract
- [x] Generate Behavior Pool
- [x] Generate RAP handler and saver structures

## Transactional Buffer

- [x] Define Header transactional buffer
- [x] Define operation states
- [x] Implement state consolidation rules
- [x] Implement buffer cleanup

## Header Operations

- [x] Header CREATE
- [x] Early Header UUID generation
- [x] Initial business status
- [x] Administrative field initialization
- [x] Header READ
- [x] Header UPDATE
- [x] Partial update using `%control`
- [x] Header DELETE

## Save Sequence

- [x] Persist created Headers
- [x] Persist updated Headers
- [x] Persist deleted Headers
- [x] Clear Header buffer after save

## Testing

- [x] Configure CDS Test Double Framework
- [x] Enable double redirection
- [x] Test Header CREATE
- [x] Test transactional READ
- [x] Test CREATE → UPDATE
- [x] Test CREATE → DELETE
- [x] Test persisted UPDATE
- [x] Test persisted DELETE
- [x] Test CREATE persistence
- [x] Test UPDATE persistence
- [x] Test DELETE persistence

---

# 17. Remaining Sprint Work

Sprint 2 is not yet complete.

## Item Transactional Lifecycle

- [ ] Implement Item Create-by-Association
- [ ] Generate Item UUID
- [ ] Generate sequential Item Number
- [ ] Link Item to Header
- [ ] Implement RAP key mapping for Item
- [ ] Implement Item READ
- [ ] Implement Item UPDATE
- [ ] Implement Item DELETE

## Aggregate Navigation

- [ ] Implement Header → Item Read-by-Association
- [ ] Validate Header–Item transactional navigation
- [ ] Ensure buffered Items are visible before persistence

## Aggregate Persistence

- [ ] Persist created Items
- [ ] Persist updated Items
- [ ] Persist deleted Items
- [ ] Implement Header delete child cleanup
- [ ] Validate Header and Item consistency during save

## Error Handling

- [ ] Handle persistence errors
- [ ] Implement RAP `FAILED`
- [ ] Implement RAP `REPORTED`
- [ ] Introduce business-friendly messages

## Additional Tests

- [ ] Item CREATE test
- [ ] Item READ test
- [ ] Item UPDATE test
- [ ] Item DELETE test
- [ ] Create-by-Association test
- [ ] Multiple Item numbering test
- [ ] Header–Item navigation test
- [ ] Aggregate save test
- [ ] Aggregate consistency test
- [ ] Transaction rollback test

---

# 18. Definition of Done

Sprint 2 will be considered complete when:

- Header and Item transactional operations are implemented.
- Header and Item changes are buffered before persistence.
- Create-by-Association works correctly.
- Technical UUIDs are generated during the interaction phase.
- Item numbering is generated consistently inside each Purchase
  Requisition.
- Header–Item navigation works before and after persistence.
- The RAP save sequence correctly persists Header and Item operations.
- Aggregate consistency is maintained.
- Transactional buffers are correctly cleaned.
- Persistence errors are handled.
- RAP failures and messages are returned correctly.
- Automated tests cover the complete transactional foundation.
- Architecture and sprint documentation are updated.

---

# 19. Current Sprint Checkpoint

At the current checkpoint:

```text
Purchase Requisition
│
├── Header
│   ├── CREATE              ✅
│   ├── READ                ✅
│   ├── UPDATE              ✅
│   ├── DELETE              ✅
│   ├── Transaction Buffer  ✅
│   ├── Save Sequence       ✅
│   ├── Cleanup             ✅
│   └── ABAP Unit Tests     ✅ 9/9
│
└── Item
    ├── CBA                 ⬜
    ├── UUID                ⬜
    ├── Item Numbering      ⬜
    ├── READ                ⬜
    ├── UPDATE              ⬜
    ├── DELETE              ⬜
    ├── Navigation          ⬜
    ├── Persistence         ⬜
    └── ABAP Unit Tests     ⬜
```

The Header transactional foundation is therefore complete.

The next implementation milestone is the Item lifecycle beginning with
Create-by-Association.

---

# 20. Next Step

The next development task is:

```text
Implement Purchase Requisition Item Create-by-Association
```

The implementation will introduce:

- Parent Header UUID resolution
- Early Item UUID generation
- Sequential Item numbering
- Item transactional buffering
- Item RAP key mapping
- Header–Item aggregate behavior

This will transition the Purchase Requisition implementation from a
single transactional entity into a fully transactional RAP aggregate.