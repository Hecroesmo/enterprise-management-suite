# ADR-007 — Status Strategy


Decisão: representar os estados através de:

ZEMSD_PR_STATUS
       ↓
ZEMSE_PR_STATUS

Estados atuais:

- C = Created
- S = Submitted
- A = Approved
- R = Rejected
- X = Cancelled

As transições serão controladas pelo Behavior, e não apenas pelo Domain.

Exemplo:

Created → Submitted   OK
Submitted → Approved  OK
Approved → Created    Not OK


Status: Accepted.
