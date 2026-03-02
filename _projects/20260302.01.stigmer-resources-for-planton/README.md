# Project: 20260302.01.stigmer-resources-for-planton

## Overview
Create Stigmer resources (MCP server, 5 AI agents, skills, and shell-script tooling) for the Planton platform, demonstrating how Stigmer-powered agents can make Planton's infrastructure management accessible without dedicated DevOps expertise.

**Created**: 2026-03-02
**Status**: Active

## Project Information

### Primary Goal
Build a complete Stigmer project that defines an MCP server connecting to Planton's API, 5 high-value AI agents with deep domain skills, and reproducible shell-script tooling — producing a public showcase of Stigmer's value for Planton.

### Timeline
**Target Completion**: 2-3 weeks (one phase per session)

### Technology Stack
Stigmer (agents/skills/MCP YAML), Shell scripting (tools/), Planton CLI, Planton Protobuf APIs, OpenMCF

### Project Type
Feature Development

### Affected Components
New repository: plantonhq/agent-fleet (MCP server definition, agent YAMLs, skill SKILL.md files, shell tool scripts)

## Project Context

### Dependencies
- Stigmer CLI installed and operational
- Planton CLI installed for MCP server connectivity
- Access to Planton documentation (sibling `../planton/` clone)
- Existing `plantonhq/mcp-server-planton` repo for MCP server implementation context

### Success Criteria
- MCP server YAML correctly defines all Planton API tools
- All 5 agents have well-crafted skills with rich domain knowledge
- Shell scripts in tools/ can regenerate all skills end-to-end
- A new user can register the project with Stigmer and use the agents immediately
- Demo narrative is compelling for the Planton founder

### Known Risks & Mitigations
- Planton docs are in a private repo; mitigated by bundling curated excerpts in skills/*/references/
- MCP server implementation may not be feature-complete; mitigated by defining the YAML spec first and iterating
- Stigmer draft skill quality depends on context quality; mitigated by careful doc curation per agent

## Project Structure

This project follows the **Next Project Framework** for structured multi-day development:

- **`tasks/`** - Detailed task planning and execution logs (update freely)
- **`checkpoints/`** - Major milestone summaries
- **`design-decisions/`** - Significant architectural choices
- **`coding-guidelines/`** - Project-wide code standards
- **`wrong-assumptions/`** - Important misconceptions
- **`dont-dos/`** - Critical anti-patterns

## Current Status

### Active Task
See [tasks/](tasks/) for the current task being worked on.

### Progress Tracking
- [x] Project initialized
- [ ] Phase 0: Repository scaffold and Stigmer project manifest
- [ ] Phase 1: Planton MCP Server definition
- [ ] Phase 2: Cloud Resource Assistant (agent + skill)
- [ ] Phase 3: Stack Job Troubleshooter (agent + skill)
- [ ] Phase 4: Infra Chart Composer (agent + skill)
- [ ] Phase 5: Planton Onboarding Guide (agent + skill)
- [ ] Phase 6: Service Pipeline Debugger (agent + skill)
- [ ] Phase 7: Tooling, automation, and final README

## How to Resume Work

**Quick Resume**: Drag and drop `next-task.md` into your AI conversation.

## Quick Links

- [Next Task](next-task.md) - **Drag this into chat to resume**
- [Current Task](tasks/)
- [Latest Checkpoint](checkpoints/)
- [Design Decisions](design-decisions/)
