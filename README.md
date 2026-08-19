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
```

---

## 2. Core Roles & Autonomous Triggers

Each model specification includes an **Autonomous Trigger Resolution Rule (Rule 6)**, allowing you to activate agents in GUI environments (such as Antigravity, Claude Cowork, or Cursor) with single-phrase prompts:

| Model | Specification | Primary Role | Accepted Trigger Phrases |
| :--- | :--- | :--- | :--- |
| **PLANNER** | `rules/planning.md` | **Sole Authority of Change.** Synthesizes briefs/reviews into strict blueprints (`plan.md`). | `"You're up!"`, `"Plan"`, `"Go"`, `"Next"` |
| **BUILDER** | `rules/building.md` | **Senior Implementation Engineer.** Executes `plan.md` with zero deviations and clean Git commits. | `"You're up!"`, `"Build"`, `"Execute"`, `"Go"` |
| **REVIEWER** | `rules/reviewing.md` | **Principal Code Auditor.** Pure QA static analysis. Strictly zero direct file edits. | `"You're up!"`, `"Review"`, `"Audit"`, `"Go"` |
| **LEAD (Human)**| `rules/workflow.md` | Human-in-the-loop tester, escalation arbiter, and release merge authority. | — |

---

## 3. File Matrix & Directory Layout

```text
ai-workflow-templates/
├── rules/
│   ├── planning.md          # Architect system prompt & plan.md schema
│   ├── building.md          # Implementation engineer prompt & handover.md schema
│   ├── reviewing.md         # Auditor system prompt & review.md schema
│   └── workflow.md          # Master 5-stage lifecycle and invariant rules
├── scripts/
│   └── setup-project.ps1    # Interactive project generator & remote fetcher
└── README.md
```

---

## 4. Quick Start: Scaffolding a New Project

Run the scaffolding script directly in PowerShell from any terminal to initialize a project linked dynamically to this repository:

```powershell
# Run setup interactively
irm [https://raw.githubusercontent.com/0mattsmith/ai-workflow-templates/main/scripts/setup-project.ps1](https://raw.githubusercontent.com/0mattsmith/ai-workflow-templates/main/scripts/setup-project.ps1) | iex
```

**What the setup script does:**
1. Prompts for **Project Name** and **Destination Directory** (defaults to `Documents\Development\<ProjectName>`).
2. Ingests an initial brief via drag-and-drop file path or interactive multi-line terminal paste.
3. Creates standard workspace scaffolding (`.workflow/active`, `.workflow/archive`, `src`, `tests`).
4. Generates a project-local `workflow.ps1` runner that dynamically fetches fresh rules from GitHub.
5. Initializes a local Git repository with a baseline commit on branch `main`.

---

## 5. Daily Project Operations

### Terminal / CLI Mode (`workflow.ps1`)

```powershell
# 1. Trigger Planning Model (creates .workflow/active/plan.md)
.\workflow.ps1 plan

# 2. Trigger Building Model (executes plan.md, commits, creates .workflow/active/handover.md)
.\workflow.ps1 build

# 3. Trigger Reviewing Model (audits diff & proofs, generates .workflow/active/review.md)
.\workflow.ps1 review

# Check active artifact status and clean Git tree status
.\workflow.ps1 status

# Synchronize local cached rules with the latest GitHub definitions
.\workflow.ps1 sync-rules

# Archive completed phase artifacts to .workflow/archive/phase-01/
.\workflow.ps1 archive -PhaseName "phase-01"

# Launch 3 dedicated, pre-primed terminal tabs for each worker
.\workflow.ps1 launch-workers
```

### GUI / IDE Mode (Antigravity, Claude Cowork, Cursor)

1. Open 3 persistent tabs/sessions named **`[01] Planner`**, **`[02] Builder`**, and **`[03] Reviewer`**.
2. Point each session once to its respective rule file (`.workflow/rules/planning.md`, etc.).
3. Advance the project through the stages by typing **`"You're up!"`** or **`"Go"`** in the appropriate tab.

---

## 6. Rules of Engagement

1. **Deterministic Blueprints:** No placeholder instructions (`// TODO`, `implement as needed`).
2. **Raw Execution Proofs:** Handover reports require verbatim exit codes and linter/test terminal outputs.
3. **No Direct Reviewer Edits:** The Reviewer identifies and proposes; the Planner codifies; the Builder implements.
4. **Context Hygiene:** Past iterations are archived after each phase to keep the workspace and LLM context window minimal.
