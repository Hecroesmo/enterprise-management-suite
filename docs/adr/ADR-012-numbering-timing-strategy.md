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
