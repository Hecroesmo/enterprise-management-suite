# ADR-005 – Standard SAP Object Reuse

## Status

Accepted

## Context

EMS requires many common SAP business concepts such as Company Code, Plant, Material, Currency, Unit of Measure, SAP User, and Purchase Requisition Item Number.

Creating custom Data Elements and Domains for concepts that already exist in SAP would duplicate semantics and increase maintenance effort.

## Decision

EMS will reuse SAP standard Dictionary objects whenever their business meaning correctly matches the EMS requirement.

Examples include:

- `BUKRS` – Company Code
- `WERKS_D` – Plant
- `MATNR` – Material
- `MEINS` – Unit of Measure
- `WAERS` – Currency
- `SYUNAME` – SAP User
- `BNFPO` – Purchase Requisition Item Number

Custom EMS objects such as `ZEMSE_*` and `ZEMSD_*` will only be created when EMS introduces its own business semantics.

## Alternatives Considered

### Create custom objects for every EMS field

Advantages:

- Complete technical ownership.
- Uniform EMS naming.

Disadvantages:

- Duplicates existing SAP concepts.
- Increases maintenance.
- Loses standard SAP semantics.
- Makes integration more difficult.

### Always reuse SAP standard objects

Advantages:

- Maximum reuse.

Disadvantages:

- Incorrect when the EMS field has different semantics from the SAP standard concept.

### Reuse when semantics match

Advantages:

- Maintains SAP semantics.
- Avoids unnecessary custom development.
- Allows custom modeling when genuinely required.

## Rationale

Reusing a SAP standard object is not merely a technical optimization.

It also reuses established business meaning, metadata, validation characteristics, documentation, and integration semantics.

The deciding factor is semantic compatibility, not simply whether a similarly named SAP object exists.

## Consequences

### Positive

- Reduced custom development.
- Better semantic alignment with SAP.
- Improved maintainability.
- Easier integration with SAP processes.
- Supports Clean Core-oriented development principles.

### Negative / Trade-offs

- Developers must verify semantic compatibility before reuse.
- Some standard objects may have historical characteristics that differ from the ideal EMS design.

## Related Decisions

- ADR-001 – Data Model Strategy
- ADR-004 – Enhancement Strategy
- ADR-007 – Status Strategy
