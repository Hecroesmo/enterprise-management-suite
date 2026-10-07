# ZEMSD_PR_STATUS – Purchase Requisition Status

## Object Type

DDIC Domain

## Technical Name

`ZEMSD_PR_STATUS`

## Purpose

Defines the allowed business status values for the EMS Purchase
Requisition Header.

The domain provides the basic value constraint for the Purchase
Requisition lifecycle.

Business transition rules are not enforced by the domain itself.
They are implemented in the RAP Behavior layer.

---

## Technical Definition

| Property | Value |
|---|---|
| Data Type | `CHAR` |
| Length | `1` |
| Output Length | `1` |
| Case Sensitive | No |
| Conversion Routine | None |
| Value Definition | Fixed Values |

---

## Fixed Values

| Value | Description |
|---|---|
| `C` | Created |
| `S` | Submitted |
| `A` | Approved |
| `R` | Rejected |
| `X` | Canceled |

---

## Business Meaning

The domain restricts the status field to known Purchase Requisition
business states.

The currently defined lifecycle states are:

```text
C – Created
S – Submitted
A – Approved
R – Rejected
X – Canceled

The domain validates that only supported status codes can be stored.
It does not determine whether a transition between two valid states is
allowed.

For example:

    |   Created → Submitted

may be valid, while:

    |   Created → Approved

may be rejected by the Business Object.

Those transition rules are implemented separately in the RAP Behavior
layer.

## Usage

The domain is referenced by data element:

```text
ZEMSE_PR_STATUS

which is used by:

```text
ZEMST_PR_HDR-STATUS

## Related Architecture Decisions
- ADR-007 – Purchase Requisition Status Strategy
- ADR-010 – RAP Implementation Strategy

## Notes

The business status is independent from RAP transactional state.
For example:

    |   Status = C

means:

    |   Created

while:

    |   Buffer Operation = C

means:

    |   Create during the current transaction

The identical code value represents different concepts depending on the
context.