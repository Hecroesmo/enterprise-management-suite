# ADR-010 — RAP Implementation Strategy


Contexto ambiental:

    |  SAP S/4HANA 1909
    |  ABAP Platform 1909
    |  SAP_BASIS 7.54 SP03

As capacidades disponíveis nessa release fazem com que implementemos o Business Object utilizando Unmanaged RAP.

Decisão:

Persistence Tables

       
       
DDIC-based CDS Views

       
       
Unmanaged Behavior Definition

       
       
Unmanaged Behavior Implementation

       
       
Projection

       
       
Service

Não utilizaremos Managed RAP nesta implementação. Isso significa que teremos responsabilidade explícita por:

- CREATE

- UPDATE

- DELETE

- READ

- Buffer transacional

- Key mapping

- Messages

- Validations

- Locks

- Save sequence

- UUID generation

Consequência positiva: o projeto demonstra compreensão profunda do RAP, incluindo mecanismos que são abstraídos pelo Managed Scenario.

Status: Accepted.
