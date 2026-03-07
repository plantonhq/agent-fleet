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
| 2 | Cloud Resource Assistant (agent + skill) | Pending |
| 3 | Stack Job Troubleshooter (agent + skill) | Pending |
| 4 | Infra Chart Composer (agent + skill) | In Progress |
| 5 | Planton Onboarding Guide (agent + skill) | Pending |
| 6 | Service Pipeline Debugger (agent + skill) | Pending |
| 7 | Tooling, automation, final README | Pending |

## Session History

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
**Current Task**: Phase 4 — Infra Chart Composer (agent + skill)
**Status**: In Progress — tool scripts created, awaiting manual execution

**Current step:**
- Done: Phase 0 — Repository scaffold + Stigmer manifest (2026-03-02)
- Done: Phase 1 — MCP server definition generated and validated
- In Progress: Phase 4 — Infra Chart Composer tool scripts ready
- Next: **Run `./tools/03_draft-infra-chart-composer-skill.sh`**, review the generated skill, then run `./tools/04_draft-infra-chart-composer-agent.sh`

## Objectives for Next Session

**Option A (Recommended):** Run the skill draft script, review generated SKILL.md and references, then run the agent draft script, review the agent YAML, and validate.

**Option B:** Iterate on the tool script prompts if the generated output needs adjustments.

**Option C:** Proceed to Phase 2 (Cloud Resource Assistant) or Phase 3 (Stack Job Troubleshooter) using the same script generation pattern.

## Quick Commands

After loading context:
- "Run Phase 4 skill draft" — Execute `./tools/03_draft-infra-chart-composer-skill.sh`
- "Run Phase 4 agent draft" — Execute `./tools/04_draft-infra-chart-composer-agent.sh`
- "Show project status" — Get overview of progress
- "Create checkpoint" — Save current progress

---

*This file provides portable paths to all project resources for quick context loading.*
