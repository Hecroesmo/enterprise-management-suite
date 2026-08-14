# ADR-008 — Header–Item Relationship


Decisão: modelar Header e Items como um único Aggregate RAP.

ZEMSI_PR_HDR
     |      
Composition
     |
ZEMSI_PR_ITEM


O Header é o Aggregate Root e o Item é dependente do ciclo de vida do Header.

O UUID do Header é armazenado fisicamente no Item:

purchase_req_uuid : sysuuid_x16;


Status: Accepted.
