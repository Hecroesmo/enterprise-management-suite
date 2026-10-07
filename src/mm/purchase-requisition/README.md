# Purchase Requisition Source Snapshots

This directory contains sanitized source snapshots of the EMS Purchase
Requisition implementation.

The snapshots are maintained for:

- Architecture review
- Portfolio documentation
- Code review
- Version history
- Technical discussion
- Learning and demonstration purposes

## Important

These files are not a direct export of a productive SAP system and are
not intended to be imported automatically into another system.

Environment-specific and organization-specific information is removed
before source code is committed to this repository.

The SAP development system remains the authoritative runtime
environment for the current implementation.

## Sanitization Rules

Source snapshots must not contain:

- SAP system identifiers
- Hostnames or IP addresses
- SAP client numbers
- Transport request numbers
- Corporate usernames
- Email addresses
- Internal company names
- Credentials or tokens
- Internal endpoints
- Production business data
- Organization-specific configuration values

Generic EMS object names and standard SAP object names may remain.

## Current Scope

The current source snapshots cover:

- DDIC persistence
- CDS interface entities
- Unmanaged RAP Behavior Definition
- Behavior implementation
- ABAP Unit tests

Service exposure and UI artifacts will be added in later sprints.