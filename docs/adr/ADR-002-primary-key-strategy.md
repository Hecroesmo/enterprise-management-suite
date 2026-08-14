
# ADR-002 — Primary Key Strategy


Decisão: utilizar UUID como chave técnica e Number Range como identificador de negócio.


Technical Key: PurchaseRequisitionUUID

Business Key: PurchaseRequisitionNumber


Motivação: UUID oferece unicidade global e favorece integrações; o número de negócio oferece legibilidade para utilizadores, documentos e suporte.


Status: Accepted.
