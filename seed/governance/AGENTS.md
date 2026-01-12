# AGENTS.md — Repo Instructions for Codex (Implementation Phase)

## Golden rule (scope control)
- Implement ONLY what is listed in `specs/<FEATURE>/tasks.md`.
- Do not add scope beyond tasks.md.
- If something important is missing, STOP and propose a `tasks.md` update (spec-only change) before coding.

## Source of truth
- Requirements: `specs/<FEATURE>/spec.md`
- Technical decisions: `specs/<FEATURE>/plan.md`
- Work breakdown: `specs/<FEATURE>/tasks.md`
- Evidence: `docs/sources/<FEATURE>/`

## Implementation loop (repeat for each batch)
1) State which tasks (checkbox items) you will implement.
2) Make the minimal set of code changes.
3) Run lint/tests.
4) Report:
   - tasks completed
   - files changed
   - how to validate (commands + expected results)

## Non-negotiables (clinic safety baseline)
- Never log raw WhatsApp message content or other PII/PHI in application logs.
- Enforce auth + RBAC on every API route.
- Every acceptance criterion must be mapped to a test or a manual validation step.

## Stack constraints (edit to match your project)
- Frontend: Node.js
- Backend: FastAPI + Python

## Project commands (fill these in for your repo)
### Backend
- Install:
  - `<ADD COMMAND>`
- Lint:
  - `<ADD COMMAND>`
- Tests:
  - `<ADD COMMAND>`
- Run:
  - `<ADD COMMAND>`

### Frontend
- Install:
  - `<ADD COMMAND>`
- Lint:
  - `<ADD COMMAND>`
- Tests:
  - `<ADD COMMAND>`
- Run:
  - `<ADD COMMAND>`
