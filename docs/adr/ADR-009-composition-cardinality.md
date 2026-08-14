# ADR-009 — Composition Cardinality


Decisão:

    |  composition [0..*] of ZEMSI_PR_ITEM as _Item

e não:

    |  composition [1..*]


Motivação: uma PR pode existir temporariamente sem itens durante a criação.


Porém existe uma Business Rule:

BR-PR-001

Uma Purchase Requisition deve possuir
pelo menos um item antes de ser submetida.

Ou seja:

Persistência/CDS

0..N Items

Business Rule no Submit

1..N Items



Esta decisão arquitetural demonstra a separação entre estrutura de dados e regra de negócio.


Status: Accepted.
