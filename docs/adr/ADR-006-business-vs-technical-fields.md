# ADR-006 – Business vs Technical Fields

## Status

Accepted

## Context

Enterprise applications frequently distinguish between the business actor responsible for a process and the technical identity responsible for creating or changing a database record.

For example, a Purchase Requisition may be created through an external integration.

In that scenario:

CREATED_BY = INTEGRATION_USER

REQUESTED_BY = BUSINESS_USER

Using technical audit fields as business ownership fields would produce incorrect authorization and reporting behavior.

## Decision

EMS will explicitly separate technical audit information from business responsibility.

Examples:

`CREATED_BY`

Represents the technical SAP user or process responsible for creating the persisted record.

`REQUESTED_BY`

Represents the business user requesting the Purchase Requisition.

Technical fields must not automatically be used to determine business ownership or business authorization.

## Alternatives Considered

### Use CREATED_BY as the requester

Advantages:

- Fewer fields.
- Simpler persistence model.

Disadvantages:

- Fails for integrations.
- Fails for migration scenarios.
- Fails for delegated creation.
- Mixes business and technical semantics.

### Maintain separate fields

Advantages:

- Correct representation of business responsibility.
- Supports integration and background processing.
- Better auditability.

## Rationale

Technical execution identity and business responsibility are independent concepts.

The distinction becomes particularly important in scenarios involving:

- APIs
- BAPIs
- Background users
- Workflow users
- Integration users
- Migration users
- Delegated request creation

## Consequences

### Positive

- Correct business ownership.
- Better auditability.
- Integration-ready model.
- More accurate authorization rules.

### Negative / Trade-offs

- Additional fields must be maintained.
- Business requester validation must be implemented independently.

## Related Decisions

- ADR-002 – Primary Key Strategy
- ADR-007 – Status Strategy
- ADR-010 – RAP Implementation Strategy
