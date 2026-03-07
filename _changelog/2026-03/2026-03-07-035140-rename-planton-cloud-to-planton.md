# Rename "Planton Cloud" to "Planton" in Agent Fleet

**Date**: March 7, 2026

## Summary

Renamed all "planton-cloud" and "Planton Cloud" references to "planton" / "Planton" across the agent-fleet repository. This includes the MCP server onboarding scripts, project plans, changelogs, and deletion of the stale `mcp-servers/planton-cloud.yaml` file (to be regenerated as `planton.yaml`). Also updated `PLANTON_CLOUD_ENVIRONMENT` references to `PLANTON_ENVIRONMENT`.

## Problem Statement

The product name changed from "Planton Cloud" to "Planton", but the agent-fleet repository still used the old name in tool scripts, project documentation, and the generated MCP server YAML filename.

### Pain Points

- Onboarding scripts referenced "planton-cloud" as the MCP server name/slug
- The generated YAML was named `planton-cloud.yaml` instead of `planton.yaml`
- Project plans and changelogs used the old "Planton Cloud" branding
- Environment variable references still said `PLANTON_CLOUD_ENVIRONMENT`

## Solution

### Tool Scripts

Updated both onboarding scripts to use the new naming:

- `tools/00_onboard-planton-mcp-server.sh` — Changed header comment and Stigmer agent prompt from "planton-cloud" to "planton"
- `tools/01_generate-approval-policy.sh` — Updated all 5 references to "planton-cloud" (comments, `MCP_SERVER_YAML` path, prompt text)

### Generated YAML Cleanup

Deleted `mcp-servers/planton-cloud.yaml` — will be regenerated as `mcp-servers/planton.yaml` by running the updated onboarding script.

### Documentation Updates

Updated project plans, changelogs, and cursor plans:

| File | Changes |
|------|---------|
| `_projects/.../plans/phase-1-mcp-server-tool.plan.md` | Slugs, file paths, prose, env var |
| `_projects/.../next-task.md` | File path and prose |
| `_projects/.../tasks/T01_0_plan.md` | Output path and prose |
| `_changelog/.../phase-1-planton-mcpserver-tool-script.md` | Prose and env var |
| `_changelog/.../two-script-mcp-server-onboarding.md` | Mermaid diagram filenames |
| `.cursor/plans/phase_1_mcp_server_tool_da9b7666.plan.md` | Slugs, paths, prose, env var |

## Impact

- **Stigmer agents**: Running `00_onboard-planton-mcp-server.sh` now generates `planton.yaml` instead of `planton-cloud.yaml`
- **Approval policy script**: Correctly references the new `planton.yaml` path
- **Project tracking**: All plans and changelogs reflect current naming

---

**Status**: ✅ Production Ready
**Files Changed**: 10 (9 modified + 1 deleted)
