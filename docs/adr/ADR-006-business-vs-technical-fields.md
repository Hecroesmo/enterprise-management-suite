# ADR-006 — Business vs Technical Fields


Decisão: campos técnicos não serão utilizados para representar atores de negócio.


Por exemplo:

CREATED_BY: representa quem/qual processo criou tecnicamente o registo.

Enquanto:

REQUESTED_BY: representa quem solicitou a requisição do ponto de vista do negócio.


Isso suporta cenários como:

CREATED_BY  = INTEGRATION_USER

REQUESTED_BY = HWAMBANO


Status: Accepted.
