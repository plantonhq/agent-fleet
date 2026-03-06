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
| 1 | Planton MCP Server definition | In Progress |
| 2 | Cloud Resource Assistant (agent + skill) | Pending |
| 3 | Stack Job Troubleshooter (agent + skill) | Pending |
| 4 | Infra Chart Composer (agent + skill) | Pending |
| 5 | Planton Onboarding Guide (agent + skill) | Pending |
| 6 | Service Pipeline Debugger (agent + skill) | Pending |
| 7 | Tooling, automation, final README | Pending |

## Session History

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
**Current Task**: Phase 1 — Planton MCP Server Definition
**Status**: In Progress — tool script created, awaiting manual execution of `./tools/00_create-planton-mcp-server.sh`

**Current step:**
- Done: Phase 0 — Repository scaffold + Stigmer manifest (2026-03-02)
- Done: Phase 1 tool script created (2026-03-03)
- Next: **Run tool script** to generate `mcp-servers/planton.yaml`, then review and validate

## Objectives for Next Session

**Option A (Recommended):** Execute `./tools/00_onboard-planton-mcp-server.sh`, review the generated McpServer YAML, validate with `stigmer apply --dry-run`, run discovery, and refine. Then proceed to Phase 2 (Cloud Resource Assistant).

**Option B:** Skip to Phase 2 if the McpServer YAML was already generated and validated outside this workflow.

**Option C:** Revise the tool script if the initial generation result needs prompt adjustments.

## Quick Commands

After loading context:
- "Run Phase 1 tool" — Execute the MCP server generation script
- "Continue to Phase 2" — Start Cloud Resource Assistant agent + skill
- "Show project status" — Get overview of progress
- "Create checkpoint" — Save current progress

---

*This file provides portable paths to all project resources for quick context loading.*
