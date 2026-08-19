# AI Workflow Templates

Master architectural rulesets, deterministic role specifications, and automation tooling for a tri-model AI software development workflow: **PLANNING**, **BUILDING**, and **REVIEWING**, with human-in-the-loop **TESTING** and **MERGE** gates.

---

## 1. Workflow Architecture

This repository defines a deterministic, file-contract-driven development loop designed to eliminate hallucinations, scope drift, and unauthorized code alterations across autonomous AI agents.

```text
+-----------------------------------------------------------------------------------+
|                               PROJECT LEAD (Human)                                |
|          - Defines Initial Goal / Feature Brief                                   |
|          - Arbitrates Escalations (Circuit Breaker >= 2 Loops)                    |
|          - Performs Manual Testing (TESTING Stage)                                |
|          - Grants Final Approval & Executes MERGE                                 |
+-----------------------------------------------------------------------------------+
       |                                                            ^
  (New Feature /                                            (READY_FOR_TEST /
   Test Feedback)                                            ESCALATE Directive)
       v                                                            |
+---------------+       plan.md       +---------------+       handover.md       +---------------+
|   PLANNING    |  ---------------->  |   BUILDING    |  -------------------->  |   REVIEWING   |
|     MODEL     |                     |     MODEL     |  (Clean Git Commit SHA  |     MODEL     |
| (Sole Change  |                     | (Implements   |   + Raw Proof Logs      | (Audits ONLY; |
|  Authority)   |                     |  plan strictly|   + Efficiency Notes)   |  Zero edits)  |
+---------------+                     +---------------+                         +---------------+
       ^                                                                                |
       |                   review.md (Proposed fixes / STATUS: REVISE)                  |
       +================================================================================+
