# Unmanaged RAP Transaction Lifecycle

## Overview

The EMS Purchase Requisition Business Object uses Unmanaged RAP.

The implementation separates the RAP interaction phase from database
persistence through a transactional buffer.

```mermaid
flowchart TB
    CLIENT["Consumer<br/>EML / OData / Fiori"]

    BDEF["RAP Behavior Definition"]

    HANDLER["Behavior Handler<br/>Interaction Phase"]

    BUFFER["Transactional Buffer<br/>Latest LUW State"]

    SAVER["RAP Saver<br/>Save Phase"]

    DB["Persistence<br/>ZEMST_PR_HDR / ZEMST_PR_ITEM"]

    CLIENT --> BDEF
    BDEF --> HANDLER
    HANDLER --> BUFFER
    BUFFER --> SAVER
    SAVER --> DB
```

## Transactional State

The buffer stores the effective operation required during persistence.

```mermaid
flowchart LR
    CREATE["CREATE"]
    UPDATE["UPDATE"]
    DELETE["DELETE"]

    C["C<br/>Insert"]
    U["U<br/>Update"]
    D["D<br/>Delete"]
    NONE["Ø<br/>No persistence"]

    CREATE --> C

    C -->|"UPDATE"| C
    C -->|"DELETE"| NONE

    UPDATE --> U
    U -->|"UPDATE"| U
    U -->|"DELETE"| D

    DELETE --> D
```

## Transactional Read

The transactional buffer has priority over persisted database state.

```mermaid
flowchart TB
    READ["READ Request"]

    CHECK{"Entity in buffer?"}

    DELETED{"Operation = D?"}

    BUFFER_RESULT["Return buffered state"]

    DB["Read persistence"]

    DB_RESULT["Return persisted state"]

    NOT_FOUND["No result"]

    READ --> CHECK

    CHECK -->|"Yes"| DELETED
    CHECK -->|"No"| DB

    DELETED -->|"No"| BUFFER_RESULT
    DELETED -->|"Yes"| NOT_FOUND

    DB -->|"Found"| DB_RESULT
    DB -->|"Not found"| NOT_FOUND
```

## Save Sequence

The current implementation processes the transactional buffer using a
single loop.

```mermaid
flowchart TB
    BUFFER["Transactional Buffer"]

    LOOP["LOOP over buffered instances"]

    OP{"Operation"}

    INSERT["INSERT"]
    UPDATE["UPDATE"]
    DELETE["DELETE"]

    DB["Persistence"]

    CLEANUP["Cleanup Buffer"]

    BUFFER --> LOOP
    LOOP --> OP

    OP -->|"C"| INSERT
    OP -->|"U"| UPDATE
    OP -->|"D"| DELETE

    INSERT --> DB
    UPDATE --> DB
    DELETE --> DB

    DB --> CLEANUP
```

## Test Architecture

The implementation is tested using ABAP Unit together with the CDS Test
Double Framework and double redirection.

```mermaid
flowchart TB
    TEST["ABAP Unit"]

    CDSENV["CDS Test Environment<br/>Double Redirection Enabled"]

    EML["EML / CDS Access"]

    SQL["Open SQL<br/>Persistence Access"]

    DOUBLE["Isolated Test Doubles"]

    TEST --> CDSENV

    CDSENV --> EML
    CDSENV --> SQL

    EML --> DOUBLE
    SQL --> DOUBLE
```

This allows both RAP/EML operations and direct Open SQL access inside the
unmanaged handlers and saver to operate against the same isolated test
environment.

No productive EMS persistence data is modified by the unit tests.