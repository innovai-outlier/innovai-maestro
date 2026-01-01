# ChatGPT Intake (ETL) — How to Use This Project

## What you do in a NEW chat
Paste the transcript (PT-BR or EN) and optionally attach images/diagrams.

Include this header (copy/paste):
- Repo: Pilot
- Feature name: <short-name>
- Goal: <one sentence>
- Constraints: <deadline/stack/compliance>
- Approval: <who approves + what “approved” means>
- Sources (optional): <filenames you will commit under docs/sources/...>

## What the assistant produces
- `specs/<NNN-feature>/spec.md`
- `specs/<NNN-feature>/plan.md` (only if spec is sufficiently clear; otherwise Open Questions block it)
- `specs/<NNN-feature>/tasks.md`
- Optional: constitution tweaks if you add new governance rules

## The extraction discipline
Outputs separate:
- Facts (stated in transcript)
- Assumptions (inferred, clearly labeled)
- Open Questions (must resolve before planning/implementation)

## Load step (you)
- Commit sources under `docs/sources/<feature>/`
- Commit the generated spec artifacts under `specs/<feature>/`
- Open PR #1 for spec approval; merge; then implement.
