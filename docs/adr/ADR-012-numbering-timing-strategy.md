# ADR-012 – Numbering Timing Strategy

## Status

Accepted

## Context

The EMS Purchase Requisition Business Object uses two different identifiers:

- A technical UUID used internally by the RAP Business Object and integrations.
- A human-readable Purchase Requisition Number used by business users and operational processes.

These identifiers have different lifecycle requirements.

During the RAP interaction phase, a newly created Purchase Requisition may immediately receive additional operations before the save phase.

For example:

```text
CREATE Purchase Requisition
        ↓
CREATE Item by Association
        ↓
UPDATE Purchase Requisition
        ↓
SAVE

```

The child Item must be able to reference its parent Purchase Requisition before the transaction is persisted.

Therefore, the technical key must be available during the interaction phase.

At the same time, assigning the human-readable business number too early could consume business numbers for documents that are never officially submitted.

Examples include:

Abandoned Purchase Requisitions
Transactions rejected by validation
Purchase Requisitions deleted before submission
Failed transactions
Temporary user activity that never becomes an official business document

The project therefore requires different numbering timing strategies for technical and business identifiers.


## Decision

EMS will use early numbering for technical UUIDs and deferred numbering for human-readable business identifiers.

### Technical UUIDs

Technical UUIDs will be assigned as early as possible during the RAP interaction phase.

The Purchase Requisition Header UUID will be generated during the CREATE operation.

The Purchase Requisition Item UUID will be generated during the corresponding Create-by-Association operation.

Example:

```text
CREATE Purchase Requisition
        ↓
Generate PurchaseRequisitionUUID
        ↓
Store Header in Transactional Buffer
        ↓
CREATE Item by Association
        ↓
Generate PurchaseRequisitionItemUUID
        ↓
Reference Header UUID
```

The generated technical key must remain stable for the entire Logical Unit of Work.

### Business Purchase Requisition Number

The human-readable Purchase Requisition Number will not be assigned during the initial CREATE operation.

It will only be generated when the Purchase Requisition reaches the business point at which it becomes officially relevant.

For the initial EMS process, this point is the Submit action.

Example:

```text
CREATE
   │
   ├── Generate UUID
   ├── Initialize Status
   ├── Populate Administrative Fields
   └── No Business Number Yet
          │
          ▼
       User Editing
          │
          ▼
        SUBMIT
          │
          └── Generate Purchase Requisition Number
```
The business number will therefore be independent from the technical identity of the RAP entity.

| Field                     | Assignment Timing                                                  |
| ------------------------- | ------------------------------------------------------------------ |
| `PurchaseReqUuid`         | Header `CREATE`                                                    |
| `PurchaseReqItemUuid`     | Item Create-by-Association                                         |
| `PurchaseReqUuid` on Item | Create-by-Association                                              |
| `Status`                  | Header `CREATE`                                                    |
| `CreatedBy`               | Header / Item creation                                             |
| `CreatedAt`               | Header / Item creation                                             |
| `LastChangedBy`           | Creation and subsequent modification                               |
| `LocalLastChangedAt`      | Creation and subsequent modification                               |
| `LastChangedAt`           | Initialized during creation; aggregate strategy refined separately |
| `PurchaseReqNo`           | `Submit` action                                                    |

## Alternatives Considered

### Generate all identifiers during the save phase

Advantages:

- Keys are only created for data that reaches persistence.
- No technical identifiers are generated for transactions that later fail.

Disadvantages:

- Child entities cannot reliably reference newly created parents during the interaction phase.
- Create-by-Association becomes more complex.
- Transactional identity is not stable before persistence.
- Mapping temporary request identities across multiple operations becomes harder.


### Generate both UUID and business number during CREATE

Advantages:

- All identifiers are immediately available.
- Simple implementation model.

Disadvantages:

- Business numbers may be consumed by abandoned or rejected transactions.
- Business numbering becomes unnecessarily coupled to technical entity creation.
- Temporary documents may receive official-looking business references.

### Generate UUID early and business number later

Advantages:

- Stable technical identity throughout the transaction.
- Simplifies Header–Item relationships during the interaction phase.
- Supports Create-by-Association cleanly.
- Avoids unnecessary consumption of business numbers.
- Keeps technical and business identity lifecycle independent.

Disadvantages:

- A newly created entity may temporarily have no business number.
- UI and service layers must support entities whose business number is initially empty.
- Submission logic becomes responsible for business number assignment.


## Rationale

Technical identity and business identity serve different purposes and therefore do not need to be assigned at the same point in the lifecycle.

A technical UUID is required during the interaction phase because the RAP runtime and Business Object implementation must be able to uniquely identify an instance before persistence.

This is especially important when child entities are created within the same Logical Unit of Work.

The business number, however, represents an operational reference intended for users and business processes.

Assigning it only when the Purchase Requisition is submitted avoids unnecessary number consumption and preserves the meaning of the number as a reference to an officially relevant business document.


## Consequences

Positive
- Stable technical identity exists throughout the RAP interaction phase.
- Header–Item relationships can be established before persistence.
- Create-by-Association is easier to implement.
- Business numbers are not consumed by abandoned transactions.
- Technical identity remains independent from business numbering.
- Future changes to business number format do not affect technical relationships.
  
Negative / Trade-offs
- Newly created Purchase Requisitions temporarily exist without a business number.
- The UI must tolerate an empty PurchaseReqNo before submission.
- Submission logic becomes responsible for requesting and assigning the next business number.
- Business number generation must handle concurrency correctly.


## Implementation Implications

The Header CREATE handler will be responsible for:
- Generating PurchaseReqUuid
- Initializing the default business status
- Populating administrative fields
- Writing the new instance to the transactional buffer
- Returning the mapping between the incoming RAP temporary identifier and the generated UUID

The Item Create-by-Association handler will be responsible for:
- Generating PurchaseReqItemUuid
- Using the parent PurchaseReqUuid
- Initializing administrative fields
- Writing the Item to the transactional buffer

The future Submit action will be responsible for:
- Validating submission business rules
- Requesting the next Purchase Requisition business number
- Assigning PurchaseReqNo
- Moving the document to the Submitted state


## Future Considerations

The exact format of the Purchase Requisition business number will be defined separately.

Example:

        PR-2026-000123

The mechanism used to generate the sequential portion will also be implemented separately using an appropriate SAP Number Range mechanism.

The Number Range implementation must support concurrent submissions without generating duplicate business identifiers.

## Related Decisions
- ADR-002 – Primary Key Strategy
- ADR-007 – Purchase Requisition Status Strategy
- ADR-008 – Header–Item Relationship
- ADR-010 – RAP Implementation Strategy
- ADR-011 – Transactional Buffer Strategy

  
