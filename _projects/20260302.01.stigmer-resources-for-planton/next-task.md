# Next Task: 20260302.01.stigmer-resources-for-planton

## Rules of Engagement — Read First

**When this file is loaded in a new conversation, the AI MUST:**

1. **DO NOT AUTO-EXECUTE** — Never start implementing without explicit user approval
2. **GATHER CONTEXT SILENTLY** — Read all project files without outputting
3. **PRESENT STATUS SUMMARY** — Show what's done, what's pending, agreed next steps
4. **SHOW OPTIONS** — List recommended and alternative actions
5. **WAIT FOR DIRECTION** — Do NOT proceed until user explicitly confirms

### Required Status Summary Format

When resuming this project, present:

- **Overall Objective**: Build Stigmer resources (MCP server, 5 agents, skills, tooling) for the Planton platform
- **What's Been Completed**: [Key milestones]
- **What's Pending**: [Remaining phases]
- **Agreed Focus for This Session**: [From previous session]
- **Options**: A (Recommended), B, C...

**Wait for user to say "proceed", "go", or choose an option.**

---

## Quick Resume Instructions

Drop this file into your conversation to quickly resume work on this project.

## Project: 20260302.01.stigmer-resources-for-planton

**Description**: Create Stigmer resources (MCP server, 5 AI agents, skills, shell-script tooling) for the Planton platform
**Goal**: Demonstrate Stigmer's value by building domain-expert agents for Planton's infrastructure management
**Tech Stack**: Stigmer (agents/skills/MCP YAML), Shell scripting, Planton CLI, Planton Protobuf APIs, OpenMCF
**Components**: MCP server definition, agent YAMLs, skill SKILL.md files, shell tool scripts

## Essential Files to Review

### 1. Latest Checkpoint (if exists)
```
~/scm/github.com/plantonhq/agent-fleet/_projects/20260302.01.stigmer-resources-for-planton/checkpoints/
```

### 2. Current Task
```
~/scm/github.com/plantonhq/agent-fleet/_projects/20260302.01.stigmer-resources-for-planton/tasks/
```

### 3. Project Documentation
- **README**: `~/scm/github.com/plantonhq/agent-fleet/_projects/20260302.01.stigmer-resources-for-planton/README.md`
- **Plan (detailed)**: `~/scm/github.com/plantonhq/agent-fleet/_projects/20260302.01.stigmer-resources-for-planton/tasks/T01_0_plan.md`

### 4. Related Repositories
- **Planton monorepo**: `~/scm/github.com/plantonhq/planton/` (docs, APIs, platform code)
- **MCP Server implementation**: `~/scm/github.com/plantonhq/mcp-server-planton/`
- **OpenMCF**: `~/scm/github.com/plantonhq/openmcf/`
- **Stigmer**: `~/scm/github.com/stigmer/stigmer/` (seedpack reference)

## Knowledge Folders to Check

### Design Decisions
```
~/scm/github.com/plantonhq/agent-fleet/_projects/20260302.01.stigmer-resources-for-planton/design-decisions/
```

### Wrong Assumptions
```
~/scm/github.com/plantonhq/agent-fleet/_projects/20260302.01.stigmer-resources-for-planton/wrong-assumptions/
```

### Don't Dos
```
~/scm/github.com/plantonhq/agent-fleet/_projects/20260302.01.stigmer-resources-for-planton/dont-dos/
```

## Resume Checklist

When starting a new session:

1. [ ] Read the latest checkpoint from `checkpoints/`
2. [ ] Check current task status in `tasks/`
3. [ ] Review any design decisions in `design-decisions/`
4. [ ] Check lessons learned in `wrong-assumptions/` and `dont-dos/`
5. [ ] Continue with the next phase or complete the current one

## Phase Tracker

| Phase | Description | Status |
|-------|-------------|--------|
| 0 | Repository scaffold + Stigmer manifest | Done |
| 1 | Planton MCP Server definition | Done |
| 2 | Cloud Resource Assistant (agent + skill) | In Progress |
| 3 | Stack Job Troubleshooter (agent + skill) | In Progress |
| 4 | Infra Chart Composer (agent + skill) | In Progress |
| 5 | Planton Onboarding Guide (agent + skill) | In Progress |
| 6 | Service Pipeline Debugger (agent + skill) | In Progress |
| 7 | Tooling, automation, final README | Pending |

## Session History

### Session 5: Phases 3, 5, 6 — Remaining Agent Tool Scripts (2026-03-08)

**Created tool scripts for the three remaining agents in a single session.**

**What was delivered:**

1. **Stack Job Troubleshooter (Phase 3):**
   - `tools/07_draft-stack-job-troubleshooter-skill.sh` — Skill draft script. Prompt describes the agent's role as a senior SRE diagnosing failed Stack Jobs. Guides the skill-creator to explore what-is-a-stack-job.md, 66+ stack-job changelogs (error transparency, status sync, cancellation, stack input errors), and protobuf definitions (StackJob, StackJobStatus, StackJobProgressEvent, IaC operation states, Terraform/Pulumi engine events). Emphasizes the IaC operation step model (init -> refresh -> preview -> apply/destroy), common failure patterns, and the retry vs fix-and-reapply decision framework.
   - `tools/08_draft-stack-job-troubleshooter-agent.sh` — Agent draft script. Tool profile: read + diagnostic + limited-operational (rerun/resume). Can read stack jobs, progress events, IaC resources, stack inputs, and error recommendations. Cancel requires approval. Does NOT manage Cloud Resource lifecycle.

2. **Planton Onboarding Guide (Phase 5):**
   - `tools/09_draft-planton-onboarding-guide-skill.sh` — Skill draft script. Prompt describes the agent as a patient platform educator. Guides the skill-creator to explore ALL what-is docs across every domain (Infra Hub 10 articles, Service Hub 4, Connect 5, Security 3, Runner 2, Cloud Ops 1), resource hierarchy docs, connection docs, and the web console's 8-task onboarding checklist. Includes a terminology glossary requirement covering all core Planton terms.
   - `tools/10_draft-planton-onboarding-guide-agent.sh` — Agent draft script. Tool profile: strictly read-only. Can look up orgs, envs, resource kinds, connections for contextual answers. No write or destructive tools.

3. **Service Pipeline Debugger (Phase 6):**
   - `tools/11_draft-service-pipeline-debugger-skill.sh` — Skill draft script. Prompt describes the agent as a senior CI/CD reliability engineer. Guides the skill-creator to explore Service Hub what-is docs, self-managed pipeline guides (Tekton), pipeline changelogs, and protobuf definitions (Pipeline, PipelineBuildStage, PipelineDeploymentStage, TektonPipeline, TektonTask, ServicePipelineConfiguration). Covers the three-stage model (Creation -> Build -> Deploy), build method variations (Dockerfile, Buildpacks, self-managed Tekton), Kustomize context, and comprehensive failure pattern catalogs for build, deploy, and trigger failures.
   - `tools/12_draft-service-pipeline-debugger-agent.sh` — Agent draft script. Tool profile: read + diagnostic + limited-operational (retrigger/rerun). Can read services, pipelines, build/deploy stages, task logs, configurations. Does NOT manage Service lifecycle.

**Key Decisions Made:**
- Script numbers 07-12 (sequential pairs continuing from existing 06)
- All three agents follow the same shell boilerplate and convention rule
- Tool profiles differentiated by role: troubleshooters get read+diagnostic+rerun, onboarding guide is strictly read-only
- Stack Job Troubleshooter: leveraged discovery of 66+ changelogs and existing getErrorResolutionRecommendation RPC pattern
- Onboarding Guide: broadest knowledge scope — covers ALL platform domains, not just one
- Service Pipeline Debugger: covers both platform-managed and self-managed (Tekton) pipeline modes

**Files Changed/Created:**
- `tools/07_draft-stack-job-troubleshooter-skill.sh` — New skill draft script
- `tools/08_draft-stack-job-troubleshooter-agent.sh` — New agent draft script
- `tools/09_draft-planton-onboarding-guide-skill.sh` — New skill draft script
- `tools/10_draft-planton-onboarding-guide-agent.sh` — New agent draft script
- `tools/11_draft-service-pipeline-debugger-skill.sh` — New skill draft script
- `tools/12_draft-service-pipeline-debugger-agent.sh` — New agent draft script
- `_projects/.../next-task.md` — Updated status

---

### Session 4: Phase 2 — Cloud Resource Assistant Tool Scripts (2026-03-08)

**Created tool scripts for the Cloud Resource Assistant agent.**

**What was delivered:**

1. **`tools/05_draft-cloud-resource-assistant-skill.sh`** — Runs `stigmer draft skill` with the Planton monorepo as workspace. Prompt is discovery-oriented: describes the agent's role as a senior cloud infrastructure specialist, guides the skill-creator to explore what-is docs (Cloud Resources, Cloud Resource Kinds, Cloud Objects, Cloud Object Presets, OpenMCF), production Cloud Resource YAML manifests, changelogs, and proto APIs. Emphasizes schema discovery via MCP resources (`cloud-resource-kinds://catalog`, `cloud-resource-schema://{kind}`), preset-first workflow, and resource ID patterns.

2. **`tools/06_draft-cloud-resource-assistant-agent.sh`** — Runs `stigmer draft agent` with agent-fleet as workspace. Reads the generated skill and MCP server YAML. Key difference from Infra Chart Composer: explicitly instructs the agent-creator to select BOTH read AND write tools (create, update, apply) since this agent manages the full Cloud Resource lifecycle, not just file composition. Destructive tools (delete, destroy, force-unlock) are included but covered by the MCP server's approval policy.

**Key Decisions Made:**
- Used script numbers 05 and 06 (next available pair after 00, 01, 03, 04)
- Agent needs read+write tool access (distinct from Infra Chart Composer's read-only profile)
- Prompt emphasizes "preset-first" workflow — always check presets before building from scratch
- Schema discovery is critical — agent must fetch schemas on-demand, never guess field names
- Resource ID pattern (`<kind-prefix>-<org>-<name>`, max 27 chars) included in skill prompt

**Files Changed/Created:**
- `tools/05_draft-cloud-resource-assistant-skill.sh` — New skill draft script
- `tools/06_draft-cloud-resource-assistant-agent.sh` — New agent draft script
- `_projects/.../next-task.md` — Updated status

---

### Session 3: Phase 4 — Infra Chart Composer Tool Scripts (2026-03-08)

**Created tool scripts and conventions rule for the Infra Chart Composer agent.**

**What was delivered:**

1. **`tools/03_draft-infra-chart-composer-skill.sh`** — Runs `stigmer draft skill` with the Planton monorepo as workspace. Prompt is discovery-oriented: describes the agent's role and tells the skill-creator to explore what-is docs, real chart examples, changelogs, and proto APIs in the workspace.

2. **`tools/04_draft-infra-chart-composer-agent.sh`** — Runs `stigmer draft agent` with agent-fleet as workspace. Reads the generated skill and MCP server YAML, discovers available tools from MCP server capabilities, and selects appropriate read-only tools for the composer role.

3. **`.cursor/rules/generate-stigmer-draft-scripts.mdc`** — Cursor rule that codifies conventions for generating stigmer draft scripts, so future agents can be created without re-explaining the principles.

**Key Decisions Made:**
- Separate scripts per `stigmer draft` command (skill and agent in distinct files)
- Prompts are intent-driven and discovery-oriented — no hardcoded paths, tool lists, or field structures
- The Stigmer agent explores the workspace to discover documentation patterns (what-is docs, changelogs, proto APIs, production examples)
- Agent tool selection is determined by the agent-creator from MCP server discovered capabilities, not prescribed in the prompt
- Skipping Phases 2-3 to work on Phase 4 first

**Files Changed/Created:**
- `tools/03_draft-infra-chart-composer-skill.sh` — New skill draft script
- `tools/04_draft-infra-chart-composer-agent.sh` — New agent draft script
- `.cursor/rules/generate-stigmer-draft-scripts.mdc` — New convention rule
- `_projects/.../next-task.md` — Updated status

---

### Session 2: Phase 1 Tool Script (2026-03-03)

**Created the `stigmer draft mcp-server` tool script for Phase 1.**

**What was delivered:**

1. **`tools/00_create-planton-mcp-server.sh`** — Shell script that invokes `stigmer draft mcp-server` to generate the Planton McpServer YAML
   - Workspace: Planton monorepo (for deep domain understanding)
   - Spotlight attachments: `docs/product/infra-hub`, `docs/product/service-hub`, `what-is-a-planton-api-resource.md`
   - Output: `mcp-servers/` directory
   - Rich prompt covering server connection details, workspace exploration guidance, tool approval policies, and quality standards

2. **Implementation plan** — `plans/phase-1-mcp-server-tool.plan.md`

**Key Decisions Made:**
- Workspace is Planton monorepo only (not mcp-server-planton) per user direction
- Server connection details embedded in prompt message to compensate
- `default_enabled_tools` left empty (all tools); each agent narrows via its own `enabled_tools`
- `default_tool_approvals` includes 16 destructive operations with `{{args.field}}` placeholders
- Post-generation discovery step verifies exact tool names
- `PLANTON_REPO` env var override for portability

**Files Changed/Created:**
- `tools/00_create-planton-mcp-server.sh` — New tool script (Phase 1)
- `_projects/20260302.01.stigmer-resources-for-planton/next-task.md` — Updated status
- `_projects/20260302.01.stigmer-resources-for-planton/plans/` — Saved implementation plan

---

### Session 1: Repository Scaffold (2026-03-02)

**Created the agent-fleet repository and project tracking structure (Phase 0).**

---

## Current Status

**Created**: 2026-03-02
**Current Task**: All agent tool scripts created — ready to run draft commands
**Status**: All 5 agent pairs have tool scripts; awaiting manual execution

**Current step:**
- Done: Phase 0 — Repository scaffold + Stigmer manifest (2026-03-02)
- Done: Phase 1 — MCP server definition generated and validated
- In Progress: Phase 2 — Cloud Resource Assistant tool scripts ready (05, 06)
- In Progress: Phase 3 — Stack Job Troubleshooter tool scripts ready (07, 08)
- In Progress: Phase 4 — Infra Chart Composer tool scripts ready (03, 04)
- In Progress: Phase 5 — Planton Onboarding Guide tool scripts ready (09, 10)
- In Progress: Phase 6 — Service Pipeline Debugger tool scripts ready (11, 12)
- Next: **Run the draft scripts**, review output, iterate

## Objectives for Next Session

**Option A (Recommended):** Start executing draft scripts. Run skill scripts first (they generate the SKILL.md that agent scripts depend on), then agent scripts. Suggested order: Phase 4 (03, 04), Phase 2 (05, 06), Phase 3 (07, 08), Phase 5 (09, 10), Phase 6 (11, 12).

**Option B:** Run a single agent's pair end-to-end (skill + agent), review and iterate on quality before proceeding to the next.

**Option C:** Iterate on existing tool script prompts if adjustments are needed before running.

## Quick Commands

After loading context:
- "Run Phase 2 skill draft" — Execute `./tools/05_draft-cloud-resource-assistant-skill.sh`
- "Run Phase 2 agent draft" — Execute `./tools/06_draft-cloud-resource-assistant-agent.sh`
- "Run Phase 3 skill draft" — Execute `./tools/07_draft-stack-job-troubleshooter-skill.sh`
- "Run Phase 3 agent draft" — Execute `./tools/08_draft-stack-job-troubleshooter-agent.sh`
- "Run Phase 4 skill draft" — Execute `./tools/03_draft-infra-chart-composer-skill.sh`
- "Run Phase 4 agent draft" — Execute `./tools/04_draft-infra-chart-composer-agent.sh`
- "Run Phase 5 skill draft" — Execute `./tools/09_draft-planton-onboarding-guide-skill.sh`
- "Run Phase 5 agent draft" — Execute `./tools/10_draft-planton-onboarding-guide-agent.sh`
- "Run Phase 6 skill draft" — Execute `./tools/11_draft-service-pipeline-debugger-skill.sh`
- "Run Phase 6 agent draft" — Execute `./tools/12_draft-service-pipeline-debugger-agent.sh`
- "Show project status" — Get overview of progress
- "Create checkpoint" — Save current progress

---

*This file provides portable paths to all project resources for quick context loading.*
