# AI Workflow Templates

Master architectural rulesets, deterministic role specifications, and automation tooling for a tri-model AI software development workflow: **PLANNING**, **BUILDING**, and **REVIEWING**, with human-in-the-loop **TESTING** and **MERGE** gates[cite: 8].

---

## 1. Workflow Architecture

This repository defines a deterministic, file-contract-driven development loop designed to eliminate hallucinations, scope drift, and unauthorized code alterations across autonomous AI agents[cite: 8].

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
```

---

## 2. Core Roles & Invariants

* **PLANNING Model (`rules/planning.md`):** The **sole authority of change**[cite: 5]. Translates feature requirements and review feedback into deterministic, unambiguous blueprints (`plan.md`)[cite: 5]. Neither the Builder nor Reviewer may introduce scope or modify contracts outside of `plan.md`[cite: 5].
* **BUILDING Model (`rules/building.md`):** Executes `plan.md` with zero deviations[cite: 6]. Captures raw terminal test/linter logs, ensures a clean Git working tree, and generates `handover.md` with technical notes to accelerate review[cite: 6].
* **REVIEWING Model (`rules/reviewing.md`):** Pure static analysis and QA auditor[cite: 7]. **Strictly prohibited from modifying codebase files directly**[cite: 7]. Proposes code diffs in `review.md` and routes either back to Planning (`STATUS: REVISE`) or forward to the Project Lead (`STATUS: READY_FOR_TEST`)[cite: 7].
* **Project Lead (Human):** Final authority[cite: 8]. Performs manual acceptance testing and executes repository merges[cite: 8]. Arbitrates if the **anti-deadlock circuit breaker** triggers (exceeding 2 automated review cycles)[cite: 8].

---

## 3. File Matrix & Directory Layout

```text
ai-workflow-templates/
├── rules/
│   ├── planning.md          # Architect system prompt & plan.md schema[cite: 5]
│   ├── building.md          # Implementation engineer prompt & handover.md schema[cite: 6]
│   ├── reviewing.md         # Auditor system prompt & review.md schema[cite: 7]
│   └── workflow.md          # Master 5-stage lifecycle and invariant rules[cite: 8]
├── scripts/
│   └── setup-project.ps1    # Interactive project generator & remote fetcher
└── README.md
```

---

## 4. Quick Start: Scaffolding a New Project

Run the scaffolding script directly in PowerShell from any terminal to initialize a project linked dynamically to this repository:

```powershell
# Run setup interactively
.\scripts\setup-project.ps1
```

The setup script will:
1. Prompt for **Project Name**, **Target Directory**, and your **Initial Project Brief**.
2. Create standard folder scaffolding (`.workflow/active`, `.workflow/archive`, `src`, `tests`)[cite: 8].
3. Generate a project-local `workflow.ps1` runner that pulls fresh rules directly from GitHub at runtime.
4. Initialize a Git repository with a baseline commit and checkout `main`.

---

## 5. Daily Project Operations (`workflow.ps1`)

Inside any scaffolded project directory, use the local runner to operate the loop:

```powershell
# 1. Trigger Planning Model (creates .workflow/active/plan.md)
.\workflow.ps1 plan

# 2. Trigger Building Model (executes plan.md, commits, creates .workflow/active/handover.md)
.\workflow.ps1 build

# 3. Trigger Reviewing Model (audits diff & proofs, generates .workflow/active/review.md)
.\workflow.ps1 review

# Check active artifact status and git tree
.\workflow.ps1 status

# Archive completed phase artifacts to .workflow/archive/phase-01/
.\workflow.ps1 archive -PhaseName "phase-01"

# Launch 3 dedicated, pre-primed terminal tabs for each worker
.\workflow.ps1 launch-workers
```

---

## 6. Rules of Engagement

1. **Deterministic Blueprints:** No placeholder instructions (`// TODO`, `implement as needed`)[cite: 5, 6].
2. **Raw Execution Proofs:** Handover reports require verbatim exit codes and linter/test terminal outputs[cite: 6].
3. **No Direct Reviewer Edits:** The Reviewer identifies and proposes; the Planner codifies; the Builder implements[cite: 7, 8].
4. **Context Hygiene:** Past iterations are archived after each phase to keep the workspace and LLM context window minimal[cite: 8].
