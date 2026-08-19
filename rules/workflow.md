# AI-DRIVEN TRI-MODEL DEVELOPMENT WORKFLOW

## 1. CARDINAL ARCHITECTURAL INVARIANTS

1. **SOLE AUTHORITY OF CHANGE (PLANNING MODEL):**[cite: 8]
   * Under **NO circumstance** may ANY model (Building or Reviewing) authorize or directly implement architectural changes, scope changes, or unapproved fixes[cite: 8].
   * **The PLANNING Model is the single source of truth.** All changes must be codified into `plan.md` before execution[cite: 8].

2. **ZERO CODE-TOUCHING POLICY (REVIEWING MODEL):**[cite: 8]
   * The REVIEWING model **NEVER edits or modifies codebase files directly**[cite: 8].
   * It performs independent static/dynamic analysis, audits the builder's code and `handover.md` execution proofs, and outputs findings, proposed code fixes, and structural improvements into `review.md`[cite: 8].
   * `review.md` is passed back to the **PLANNING model**, which evaluates the recommendations and issues an updated `plan.md`[cite: 8].

3. **VERIFIABLE EXECUTION & GIT ANCHORING (BUILDING MODEL):**
   * The BUILDING model implements `plan.md` strictly as specified[cite: 8].
   * The Builder must provide raw terminal proofs (linter, typechecker, test runner exit codes) and a clean git working tree commit SHA in `handover.md`.
   * The Builder includes technical clues and edge-case notes to accelerate the Reviewer's analysis[cite: 8].

4. **ANTI-DEADLOCK CIRCUIT BREAKER:**
   * An automated phase is limited to a maximum of **2 review iterations**.
   * If a phase cannot achieve `STATUS: READY_FOR_TEST` by iteration 2, the Reviewer outputs `STATUS: ESCALATE_TO_LEAD` to bring in the human Project Lead for arbitration.

5. **NON-BLOCKING NITPICK TRIAGE:**
   * `LOW` severity or cosmetic issues do not block the pipeline. If code passes all functional, security, and architectural checks, the Reviewer issues `STATUS: READY_FOR_TEST` and logs nitpicks for lead awareness.

---

## 2. WORKSPACE & REPOSITORY ORGANIZATION

To keep the repository clean and avoid context-window bloat, active communication artifacts reside in `.workflow/active/` and are archived upon phase completion:

```text
my-project/
├── .workflow/
│   ├── active/
│   │   ├── plan.md          # Active blueprint from Planner
│   │   ├── handover.md      # Active report & execution proofs from Builder
│   │   └── review.md        # Active audit & gate decision from Reviewer
│   └── archive/
│       ├── phase-01-auth/
│       │   ├── v1.0-plan.md
│       │   ├── v1.0-handover.md
│       │   ├── v1.0-review.md
│       │   └── v1.1-final-...
│       └── phase-02-billing/
├── src/
├── tests/
└── (project files)
```

---

## 3. WORKFLOW TOPOLOGY & LIFECYCLE

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

## 4. THE 5-STAGE EXECUTION LIFECYCLE

### Stage 1: PLANNING (`planning.md` -> `plan.md`)[cite: 8]
* **Role:** System Architect & Sole Change Authority[cite: 8].
* **Inputs:** Phase requirements from Project Lead OR `review.md` / test feedback[cite: 8].
* **Execution:** Evaluates proposed fixes and structural suggestions[cite: 8]. Formulates or updates `plan.md` with explicit file matrices, contracts, step-by-step algorithms, and validation specs[cite: 8].
* **Output Artifact:** `plan.md`[cite: 8].

### Stage 2: BUILDING (`building.md` -> `handover.md`)[cite: 8]
* **Role:** Implementation Engineer[cite: 8].
* **Inputs:** `plan.md` + repository codebase[cite: 8].
* **Execution:**
  1. Checks out or creates the target branch specified in `plan.md`.
  2. Implements code and tests strictly against `plan.md`[cite: 8].
  3. Runs lint, type-check, and automated test commands; captures raw terminal output.
  4. Ensures clean working tree, commits changes, and records Git commit SHA.
  5. Populates `handover.md` with execution proofs and efficiency notes for the Reviewer[cite: 8].
* **Output Artifact:** Production code + tests + git commit + `handover.md`[cite: 8].

### Stage 3: REVIEWING (`reviewing.md` -> `review.md`)[cite: 7, 8]
* **Role:** Principal QA & Code Auditor (Read-Only / Consultative)[cite: 7, 8].
* **Inputs:** `plan.md` + `handover.md` + codebase diff at commit SHA[cite: 7, 8].
* **Execution:** Verifies execution proofs, conducts independent static/security analysis, checks plan conformance, evaluates builder notes, and categorizes findings[cite: 7, 8].
* **Decision Gate:**
  * **`STATUS: REVISE`:** Blocking defects found (Iteration < 2). Formulates proposed fixes in `review.md` and routes back to **Stage 1 (PLANNING)**[cite: 7, 8].
  * **`STATUS: ESCALATE_TO_LEAD`:** Blocking defects persist at Iteration >= 2. Triggers human arbitration.
  * **`STATUS: READY_FOR_TEST`:** Zero blocking defects (nitpicks logged non-blocking). Prepares manual test steps in `review.md` and routes to **Stage 4 (TESTING)**[cite: 7, 8].
* **Output Artifact:** `review.md`[cite: 8].

### Stage 4: TESTING (Human-in-the-Loop)[cite: 8]
* **Role:** Project Lead (Human / User)[cite: 8].
* **Inputs:** `review.md` (manual testing directives) + running application[cite: 8].
* **Execution:** Runs manual end-to-end verification, evaluates UX/behavior, tests real-world edge cases[cite: 8].
* **Decision Gate:**
  * **Feedback / Rejection:** Project Lead provides feedback back into **Stage 1 (PLANNING)**[cite: 8].
  * **Pass / Acceptance:** Project Lead approves feature completeness and proceeds to **Stage 5 (MERGE)**[cite: 8].

### Stage 5: MERGE & PHASE ADVANCEMENT[cite: 8]
* **Role:** Project Lead (Human / User) + Version Control[cite: 8].
* **Execution:**
  1. Merge feature branch into main (`git checkout main && git merge feature/...`)[cite: 8].
  2. Tag release/milestone if applicable[cite: 8].
  3. Archive stage artifacts (`mv .workflow/active/* .workflow/archive/phase-XX/`)[cite: 8].
  4. Initiate next phase starting at **Stage 1 (PLANNING)**[cite: 8].

---

## 5. ARTIFACT SPECIFICATIONS & DATA CONTRACTS

| Artifact Name | Author | Consumer | Purpose & Contents |
|:---|:---|:---|:---|
| `plan.md` | PLANNING Model | BUILDING Model | Architecture, File Matrix, Interface Contracts, Step-by-Step Logic, Validation Commands[cite: 8]. |
| `handover.md` | BUILDING Model | REVIEWING Model | Commit SHA, Clean Tree Status, Raw Test/Lint Logs, Conformance Matrix, Efficiency Notes[cite: 8]. |
| `review.md` | REVIEWING Model | PLANNING Model / Project Lead | Audit Verdict (`REVISE` / `READY_FOR_TEST` / `ESCALATE`), Blocking Defect Log with Proposed Fixes, Non-blocking Nitpicks, Testing Instructions[cite: 8]. |

---

## 6. STRICT RULES OF ENGAGEMENT

1. **Zero Unauthorized Changes:** Only the PLANNING model can authorize codebase changes[cite: 8]. Reviewer proposes, Planner authorizes, Builder executes[cite: 8].
2. **Zero Conversational Waste:** Pure technical output; no small talk, preambles, or conversational filler[cite: 8].
3. **Strict State Anchoring:** No handoffs occur on uncommitted code or unverified test summaries.
