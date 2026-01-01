# Constitution (Spec-Driven Development + Copilot + ChatGPT Intake)

## Purpose
This repository uses Spec Kit’s Spec-Driven Development (SDD) workflow as the single source of truth for building features with GitHub Copilot, using ChatGPT as an intake/ETL assistant for multimodal sources (transcripts, audio/video, screenshots, diagrams).

## Laws (non-negotiable)
1. **Intent before code.** No implementation work starts until `spec.md → plan.md → tasks.md` exists and is approved.
2. **Spec ≠ plan.** `spec.md` describes *what/why* (behavior, constraints, acceptance criteria). No implementation details.
3. **Plan is the technical contract.** `plan.md` records architecture, data model, contracts, tradeoffs, and validation approach.
4. **Tasks are executable.** `tasks.md` is dependency-ordered with GitHub checkboxes (`- [ ]`). Progress is visible by checking boxes.
5. **No silent assumptions.** Unclear requirements must become explicit **Open Questions** in the spec and be resolved before planning.
6. **Multimodal sources are evidence.** Sources must live under `docs/sources/<feature>/` and be linked from the spec.
7. **Copilot must be constrained.** `.github/copilot-instructions.md` is authoritative for Copilot behavior.
8. **Validation is part of the feature.** Every spec must define how success is validated (tests/checks/manual steps).
9. **PR gating.** Code changes must be accompanied by the relevant spec artifacts for the feature.

## Definition of Approved (per feature)
A feature is approved only when:
- `specs/<NNN-feature>/spec.md` has no unresolved Open Questions for required behavior,
- `plan.md` maps back to spec requirements,
- `tasks.md` covers the plan and is small enough to execute,
- required checks pass.
