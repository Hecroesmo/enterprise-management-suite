# Purchase Requisition Tests

Automated tests for the Purchase Requisition RAP Business Object are
implemented as local ABAP Unit test classes inside the corresponding
Behavior Pool.

Current test source:

`../behavior/zbp_emsi_pr_hdr/test-classes/ltcl_purchase_req.abap`

## Current Coverage

The current test suite validates the Purchase Requisition Header
transactional foundation, including:

- Header creation with early UUID generation
- Transactional reads before persistence
- Partial updates using RAP field control
- CREATE → UPDATE state consolidation
- CREATE → DELETE state consolidation
- UPDATE of persisted instances
- DELETE of persisted instances
- RAP save sequence for CREATE
- RAP save sequence for UPDATE
- RAP save sequence for DELETE
- Transactional buffer cleanup after save

Item and aggregate-level test coverage will be added as the Item
behavior implementation evolves.

## Test Architecture

The tests use:

- ABAP Unit
- EML operations
- CDS Test Double Environment
- Double redirection for persistence isolation
- The same transactional buffer used by the RAP behavior implementation

No production business data is required by the test suite.