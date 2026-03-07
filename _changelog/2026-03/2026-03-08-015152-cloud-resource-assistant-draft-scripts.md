# Cloud Resource Assistant Draft Scripts

**Date**: March 8, 2026

## Summary

Created tool scripts for drafting the Cloud Resource Assistant skill and agent (Phase 2), following the conventions established in Phase 4 (Infra Chart Composer). This is the highest-value agent in the fleet — it turns natural language into validated, deployable Cloud Resource manifests across Planton's 300+ resource kinds.

## Problem Statement

Phase 2 of the agent-fleet project requires a Cloud Resource Assistant — an agent that helps users create, configure, and deploy any Cloud Resource kind from natural language. This agent needs two `stigmer draft` invocations (skill and agent), each with domain-specific prompts tailored to the Cloud Resource lifecycle.

### Pain Points

- Cloud Resources span 300+ kinds across 17 providers — the agent cannot have embedded schemas and must discover them on-demand
- Unlike the Infra Chart Composer (read-only, file composition), this agent manages the full lifecycle including deployment guidance, requiring both read and write MCP tools
- Cloud Object Presets are a critical starting point for resource creation but must be fetched dynamically, not embedded
- Resource ID patterns have strict constraints (27-char limit, kind-prefix) that the skill must teach

## Solution

Two shell scripts following the established `generate-stigmer-draft-scripts` conventions:

1. **`tools/05_draft-cloud-resource-assistant-skill.sh`** — Drafts the skill with the Planton monorepo as workspace. The discovery-oriented prompt covers:
   - what-is-\* docs for Cloud Resources, Kinds, Objects, Presets, OpenMCF
   - Production Cloud Resource YAML manifests across multiple providers
   - Changelogs for wizard, preset, and validation changes
   - Protobuf API definitions for CloudResource, CloudResourceSpec, CloudObjectPreset
   - MCP resource URIs for schema discovery
   - Preset-first workflow and resource ID patterns

2. **`tools/06_draft-cloud-resource-assistant-agent.sh`** — Drafts the agent with agent-fleet as workspace. Reads the generated skill and MCP server YAML, then instructs the agent-creator to select both read AND write tools for the full resource lifecycle.

## Implementation Details

### Skill Script Prompt Design

The prompt follows the same discovery-oriented pattern as Infra Chart Composer but adds Cloud Resource-specific domain knowledge:

- **Schema discovery**: `cloud-resource-kinds://catalog` and `cloud-resource-schema://{kind}` — always fetch before writing spec fields
- **Preset-first workflow**: Check for Cloud Object Presets before building from scratch
- **Resource ID patterns**: `<kind-prefix>-<org>-<name>` with 27-char limit
- **KRM structure**: apiVersion, kind, metadata (name, org, environment, labels), spec
- **Deployment guidance**: Explain `planton apply` workflow but never auto-deploy

### Agent Script Prompt Design

The key distinction from the Infra Chart Composer agent prompt:

- Explicitly instructs agent-creator to select **read + write** tools (not read-only)
- Write tools include: create resources, update resources, apply manifests
- Destructive tools (delete, destroy, force-unlock) are included but covered by the MCP server's approval policy
- System prompt role: patient, knowledgeable specialist who confirms before any destructive action

## Benefits

- Reuses the conventions rule and shell boilerplate from Phase 4 — no structural changes needed
- Discovery-oriented prompts mean the scripts remain valid as the Planton monorepo evolves
- Read+write tool profile correctly reflects the agent's lifecycle management role
- Preset-first workflow reduces the effort for common resource types

## Impact

- Advances the agent-fleet project from 2 agents (MCP server + Infra Chart Composer) to 3 (+ Cloud Resource Assistant)
- Cloud Resource Assistant is the highest-value agent per the project plan — it directly demonstrates Planton's "no DevOps team needed" value proposition amplified by AI
- Scripts are ready for manual execution via `stigmer draft skill` and `stigmer draft agent`

## Related Work

- Phase 4: Infra Chart Composer draft scripts (`tools/03_*`, `tools/04_*`) — same pattern, read-only tool profile
- Conventions rule: `tools/rules/generate-stigmer-draft-scripts.mdc` — codifies the patterns both phases follow
- MCP server: `mcp-servers/planton.yaml` — defines the server both agents connect to

---

**Status**: Production Ready
**Timeline**: Single session
