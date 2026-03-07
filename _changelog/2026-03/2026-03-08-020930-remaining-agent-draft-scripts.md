# Complete Tool Scripts for All Five Planton Agents

**Date**: March 8, 2026

## Summary

Created the remaining 6 tool scripts (3 skill + 3 agent) for the Stack Job Troubleshooter, Planton Onboarding Guide, and Service Pipeline Debugger agents. All five agent pairs in the Planton agent-fleet now have `stigmer draft` tool scripts ready for execution.

## Problem Statement

Three of the five planned Planton agents still needed tool scripts before their skills and agent YAMLs could be generated. Without these scripts, the project was blocked at the "tool script creation" phase for Phases 3, 5, and 6.

### Pain Points

- Stack Job Troubleshooter, Planton Onboarding Guide, and Service Pipeline Debugger had no draft scripts
- Could not begin generating actual skills or agent YAMLs for these three agents
- Project was 40% complete on tool scripts (2 of 5 agent pairs)

## Solution

Created all 6 scripts in a single session, following the established conventions from `generate-stigmer-draft-scripts.mdc`. Each agent pair consists of a skill draft script (dual workspace: Planton monorepo + agent-fleet) and an agent draft script (single workspace: agent-fleet).

## Implementation Details

### Stack Job Troubleshooter (scripts 07, 08)

- Skill prompt focuses on the IaC operation step model (`init` -> `refresh` -> `preview` -> `apply/destroy`), common Terraform/Pulumi failure patterns, and a retry vs fix-and-reapply decision framework
- Leverages 66+ stack-job changelogs and the existing `getErrorResolutionRecommendation` RPC pattern
- Agent tool profile: read + diagnostic + limited-operational (rerun/resume; cancel requires approval)

### Planton Onboarding Guide (scripts 09, 10)

- Skill prompt has the broadest knowledge scope: 25+ what-is articles across 7 domains (Infra Hub, Service Hub, Connect, Security, Runner, Cloud Ops, API Resources)
- Includes the web console's 8-task onboarding checklist and a terminology glossary requirement
- Agent tool profile: strictly read-only (educator role, no infrastructure mutations)

### Service Pipeline Debugger (scripts 11, 12)

- Skill prompt covers the three-stage pipeline model (Creation -> Build -> Deploy), three build method variations (Dockerfile, Buildpacks, self-managed Tekton), and comprehensive failure pattern catalogs
- Includes Kustomize context and git webhook flow for trigger debugging
- Agent tool profile: read + diagnostic + limited-operational (retrigger/rerun)

## Benefits

- All 5 agent pairs now have tool scripts: project is 100% complete on tool script creation
- Consistent conventions across all scripts (discovery-oriented prompts, standard boilerplate)
- Tool profiles properly differentiated by agent role (read-only vs read+write vs read+diagnostic)
- Ready to begin the execution phase: running scripts to generate actual skills and agent YAMLs

## Impact

- Unblocks Phases 3, 5, and 6 of the project
- Moves project from "tool script creation" to "execution and review" phase
- All agents can now be drafted in any order

## Related Work

- Session 3: Infra Chart Composer scripts (03, 04)
- Session 4: Cloud Resource Assistant scripts (05, 06)
- Convention rule: `tools/rules/generate-stigmer-draft-scripts.mdc`

---

**Status**: Production Ready
**Timeline**: Single session
