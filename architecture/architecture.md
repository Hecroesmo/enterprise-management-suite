# EMS Architecture

This directory contains the architectural documentation for the
Enterprise Management Suite (EMS).

The documents in this directory describe how the main technical
components of EMS are structured and how they interact.

Architectural decisions that require explicit justification and
historical traceability are documented separately as Architecture
Decision Records under [`docs/adr`](../docs/adr/).

## Architecture Documents

| Document | Description |
|---|---|
| [RAP Transactional Architecture](rap-transactional-architecture.md) | Describes the Unmanaged RAP transactional architecture used by the Purchase Requisition Business Object, including the interaction phase, transactional buffer, save sequence, persistence and testing strategy. |

## Related Documentation

- [Architecture Decision Records](../docs/adr/)
- [Diagrams](../diagrams/)
- [Sprint Documentation](../docs/sprints/)
- [Purchase Requisition Source](../src/mm/purchase-requisition/)

## Current Architecture Scope

The current implementation focuses on the Materials Management domain,
starting with the Purchase Requisition Business Object.

The current technical architecture includes:

- SAP S/4HANA 1909 On-Premise
- ABAP Platform 1909
- Unmanaged RAP
- CDS-based Business Object model
- Transactional buffering
- Explicit RAP save sequence
- ABAP Unit
- CDS Test Double Framework

Additional EMS modules will be documented as they are introduced.
