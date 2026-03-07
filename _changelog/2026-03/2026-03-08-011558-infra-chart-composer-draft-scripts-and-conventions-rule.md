# Infra Chart Composer Draft Scripts and Conventions Rule

**Date**: March 8, 2026

## Summary

Created the tool scripts for drafting the Infra Chart Composer skill and agent, along with a Cursor rule that codifies conventions for generating Stigmer draft scripts. The scripts follow a discovery-oriented prompt design where the Stigmer agent explores the workspace to build domain understanding, rather than being given prescriptive file paths or hardcoded structures.

## Problem Statement

Phase 4 of the agent-fleet project requires an Infra Chart Composer — an agent that composes, modifies, and validates Planton InfraCharts. Generating this agent requires two `stigmer draft` invocations (one for the skill, one for the agent YAML), each with a carefully crafted prompt and the right workspace configuration.

### Pain Points

- No established conventions for writing `stigmer draft` shell scripts in this repo
- Initial attempts at prompts were overly prescriptive — hardcoding file paths, directory structures, MCP tool lists, and YAML field layouts that the Stigmer agent should discover on its own
- No separation between skill and agent draft commands (initially combined in one script)
- The conventions would need to be re-explained for every future agent

## Solution

Created two focused shell scripts (one per `stigmer draft` command) with discovery-oriented prompts, and a Cursor rule that captures the conventions so future agents can be generated without re-explaining the principles.

### Design Decisions

**Discovery over prescription**: Prompts describe documentation PATTERNS to search for (what-is docs, changelogs, proto APIs, production examples) rather than hardcoded paths. The Stigmer agent reads the workspace and figures out the structure.

**Separate scripts**: Each `stigmer draft` command gets its own script file. The skill draft needs the domain repo as a workspace; the agent draft only needs agent-fleet (which contains the generated skill and MCP server YAML).

**Agent determines its own tools**: The agent draft prompt tells the agent-creator to read the MCP server's discovered capabilities and select appropriate tools based on the role description, rather than prescribing a tool list.

## Implementation Details

### Tool Scripts

**`tools/03_draft-infra-chart-composer-skill.sh`**
- Runs `stigmer draft skill` with planton monorepo + agent-fleet as workspaces
- Prompt describes the agent's role (compose, modify, validate InfraCharts) and tells the skill-creator to explore the workspace for: what-is documentation articles, production InfraChart examples, changelogs showing pattern evolution, and protobuf API definitions
- Teaches schema discovery methodology (cloud-resource-kinds://catalog and cloud-resource-schema://{kind} MCP resources)
- Instructs changelog-driven learning for future-proofing

**`tools/04_draft-infra-chart-composer-agent.sh`**
- Runs `stigmer draft agent` with agent-fleet as workspace
- Prompt tells the agent-creator to read the MCP server definition and generated skill, look up discovered capabilities, and select only read-only tools appropriate for a composer role
- Describes the agent persona (principal infrastructure architect)

### Cursor Rule

**`.cursor/rules/generate-stigmer-draft-scripts.mdc`**
- Applies when working with files under `tools/**/*.sh`
- Codifies: one script per draft command, shell boilerplate conventions, prompt principles (DO: describe patterns to search for; DO NOT: hardcode paths, tool lists, field structures), workspace setup for skill vs agent drafts, documentation patterns in Planton repos

## Files Changed/Created

| File | Change |
|------|--------|
| `tools/03_draft-infra-chart-composer-skill.sh` | New — skill draft script |
| `tools/04_draft-infra-chart-composer-agent.sh` | New — agent draft script |
| `.cursor/rules/generate-stigmer-draft-scripts.mdc` | New — conventions rule |
| `_projects/.../next-task.md` | Updated — phase tracker and session history |

## Benefits

- **Reproducible**: Running the scripts generates the skill and agent from the current state of the Planton workspace, not stale embedded content
- **Resilient**: Discovery-oriented prompts survive repo reorganizations
- **Scalable**: The conventions rule means future agents (Cloud Resource Assistant, Stack Job Troubleshooter, etc.) can be created following the same pattern without re-explaining the principles
- **Clean separation**: Skill and agent are independently draftable and reviewable

## Impact

- **Phase 4 (Infra Chart Composer)**: Tool scripts ready for manual execution
- **Future phases (2, 3, 5, 6)**: Conventions rule accelerates script creation
- **Project quality**: Discovery-oriented prompts set a higher standard than prescriptive ones

## Related Work

- Phase 0: Repository scaffold (Session 1, 2026-03-02)
- Phase 1: MCP server definition scripts (Session 2, 2026-03-03)
- Planton InfraChart documentation and real chart examples in the planton monorepo

---

**Status**: In Progress — scripts created, awaiting manual execution
**Timeline**: Single session
