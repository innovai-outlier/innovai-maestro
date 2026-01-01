# Spec Kit Workflow in this Repo

## Folder conventions
- Constitution: `.specify/memory/constitution.md`
- Feature specs: `specs/<NNN-feature-name>/`
  - `spec.md` (what/why)
  - `plan.md` (how)
  - `tasks.md` (execution checklist)
- Sources/evidence: `docs/sources/<NNN-feature-name>/`

## Phase order (non-negotiable)
1) Collect sources (transcript, screenshots, diagrams) → commit to `docs/sources/<feature>/`
2) Write/approve `spec.md`
3) Write/approve `plan.md`
4) Write/approve `tasks.md`
5) Implement by executing tasks (and checking them off)

## PR pattern
- PR #1 (Specs only): sources + `spec.md` + `plan.md` + `tasks.md` (no product code)
- PR #2+ (Implementation): code changes that satisfy tasks; keep tasks checked off

## Review checklist
- Spec has clear goals, non-goals, user stories, acceptance criteria, risks, and Open Questions (if any).
- Plan maps to spec; no “orphan” architecture choices.
- Tasks are checkbox items, dependency-ordered, and trace back to spec/plan sections.
