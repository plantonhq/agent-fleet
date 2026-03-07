---
name: Phase 1 MCP Server Tool
overview: Create `tools/00_create-planton-mcp-server.sh` — a shell script that invokes `stigmer draft mcp-server` with the Planton monorepo as workspace to generate a Stigmer McpServer YAML for the Planton MCP server, outputting to agent-fleet/mcp-servers/.
todos:
  - id: create-tool-script
    content: Create `tools/00_create-planton-mcp-server.sh` — the shell script with header, path resolution, dependency checks, spotlight attachments, prompt message, and stigmer CLI invocation
    status: completed
  - id: update-next-task
    content: Update `next-task.md` Phase Tracker to mark Phase 1 as In Progress and update current task reference
    status: completed
isProject: false
---

# Phase 1: Planton MCP Server Definition — Tool Script

## What We Are Building

A single file: `[tools/00_create-planton-mcp-server.sh](agent-fleet/tools/00_create-planton-mcp-server.sh)`

This shell script invokes `stigmer draft mcp-server` to have the Stigmer `mcp-server-creator` system agent generate a production-quality `McpServer` YAML for Planton. The user executes the script manually; it is not automated.

The generated output lands at: `mcp-servers/planton.yaml` (or the slug the agent picks)

---

## Stigmer Command Shape

```bash
stigmer draft mcp-server \
  --workspace "$PLANTON_REPO" \
  --attach "$PLANTON_REPO/docs/product/infra-hub" \
  --attach "$PLANTON_REPO/docs/product/service-hub" \
  --attach "$PLANTON_REPO/docs/product/what-is-a-planton-api-resource.md" \
  --output "$REPO_ROOT/mcp-servers" \
  --env "OUTPUT_DIR=mcp-servers" \
  --model claude-sonnet-4.6 \
  -m "$(cat "${_MSG_FILE}")"
```

- `**--workspace**`: Planton monorepo (`~/scm/github.com/plantonhq/planton`). The agent can freely explore `docs/product/`, `apis/ai/planton/`, `client-apps/cli/` for deep domain understanding.
- `**--attach**` (spotlight): Key doc directories pulled from within the workspace for priority visibility.
- `**--output**`: Local download destination — `agent-fleet/mcp-servers/`.
- `**-m**`: Rich prompt message (details below).

---

## Design Decision: mcp-server-planton Context

Per your direction, the workspace is Planton only — we do **not** include `mcp-server-planton` as workspace or attachment. This means the Stigmer agent will NOT have access to the actual MCP server implementation (tool registration code, exact tool names, docs/tools.md with 100+ tool definitions).

**What we lose**: Exact tool names for `default_enabled_tools` and `default_tool_approvals`. The mcp-server-planton binary exposes 100+ tools with specific snake_case names (e.g., `apply_cloud_resource`, `destroy_cloud_resource`, `purge_cloud_resource`, `cancel_stack_job`).

**How we compensate**:

1. Leave `default_enabled_tools` empty (all tools available) — each Agent YAML narrows via its own `enabled_tools`
2. Include key destructive tool name patterns in the prompt message for `default_tool_approvals`
3. Include the server connection details (binary name, env vars, transport) directly in the prompt
4. Post-generation, run `stigmer discover mcp-server <slug>` to verify tool names and refine approvals

**Alternative** (if you reconsider): Attach just `mcp-server-planton/README.md` via `--attach` — it is 307 lines containing the binary name, env vars, tool categories, and transport modes. This is lightweight and different from using it as a workspace. Let me know if you want this.

---

## Script Architecture

Following the seedpack pattern established in `[seedpack/tools/03_draft-mcp-server-creator-skill.sh](stigmer/seedpack/tools/03_draft-mcp-server-creator-skill.sh)`:

```
tools/00_create-planton-mcp-server.sh
├── Header comment (purpose, prerequisites, usage, output)
├── set -euo pipefail
├── Path resolution
│   ├── SCRIPT_DIR, REPO_ROOT (agent-fleet/)
│   └── PLANTON_REPO (sibling: ../planton or $PLANTON_REPO env override)
├── Dependency checks (stigmer CLI, planton repo exists)
├── Configuration (paths to spotlight docs, output dir)
├── Existence verification (all attached paths exist)
├── Clean previous output
├── Progress echo (workspace, inputs, output)
├── Prompt message (temp file via mktemp, cleaned with trap)
├── stigmer draft mcp-server invocation
└── Post-generation echo (next steps)
```

### Path Resolution Strategy

The script lives in `agent-fleet/tools/`. The Planton monorepo is a sibling:

```
~/scm/github.com/plantonhq/
├── agent-fleet/     ← REPO_ROOT
├── planton/         ← PLANTON_REPO (default: ../planton relative to REPO_ROOT)
└── mcp-server-planton/  ← NOT used
```

**Portability**: `PLANTON_REPO` defaults to the sibling path but can be overridden via environment variable:

```bash
readonly PLANTON_REPO="${PLANTON_REPO:-$(cd "$REPO_ROOT/../planton" 2>/dev/null && pwd)}"
```

Fails clearly if the planton repo is not found.

---

## Prompt Message Strategy

The prompt message is the most critical component — it drives the quality of the generated YAML. It must convey:

### 1. What We Are Building

A Stigmer `McpServer` YAML for an **existing** Go binary (`mcp-server-planton`) that bridges MCP protocol to Planton's gRPC backend. We are NOT designing the server — it already exists and runs. We are declaring it for Stigmer.

### 2. Server Connection Details (embedded in prompt since mcp-server-planton not in workspace)

- **Transport**: stdio (subprocess)
- **Command**: `mcp-server-planton` (Go binary, installed via `go install` or pre-built binary)
- **Required env vars**: `PLANTON_API_KEY` (secret, API key for Planton with appropriate org permissions)
- **Optional env vars**: `PLANTON_ENVIRONMENT` (non-secret, default `live`, values: `live`/`test`/`local`)

### 3. Workspace Exploration Guidance

Direct the agent to:

- Explore `docs/product/infra-hub/` for Cloud Resources, Stack Jobs, Infra Charts, Infra Projects, Infra Pipelines
- Explore `docs/product/service-hub/` for Services, CI/CD Pipelines, Tekton
- Read `docs/product/what-is-a-planton-api-resource.md` for the API resource model
- Browse `apis/ai/planton/` for protobuf API definitions to understand the domain operations

### 4. Tool Defaults Guidance

- `default_enabled_tools`: Leave empty (all tools available). Each agent restricts via its own `enabled_tools`.
- `default_tool_approvals`: Flag destructive write operations — specifically tools that delete records, destroy infrastructure, purge resources, remove locks, or cancel running jobs. Include example patterns:
  - `delete_cloud_resource`, `destroy_cloud_resource`, `purge_cloud_resource`
  - `remove_cloud_resource_locks`
  - `delete_organization`, `delete_environment`
  - `delete_infra_project`, `undeploy_infra_project`
  - `cancel_stack_job`, `cancel_infra_pipeline`

### 5. McpServer YAML Requirements

- `apiVersion: agentic.stigmer.ai/v1`
- `kind: McpServer`
- `metadata.name`: `planton` (matching the server's conventional name)
- Rich `spec.description` that captures what this MCP server provides
- No `status` section
- Slug must match `^[a-z][a-z0-9-]*$`

---

## Validation Strategy

After the user runs the script and gets the generated YAML:

1. **Visual review**: Check the YAML structure, description quality, env_spec accuracy
2. **Schema validation**: `stigmer apply -f mcp-servers/planton.yaml --dry-run`
3. **Tool discovery**: `stigmer discover mcp-server planton` to populate `status.discovered_capabilities` and verify tool names match approval entries
4. **Refinement**: If tool names in approvals don't match discovered names, update and re-apply

These steps are documented in the script's "Next steps" output.

---

## What This Plan Does NOT Include

- Writing `mcp-servers/planton.yaml` by hand (the Stigmer agent generates it)
- Modifying the Planton monorepo
- Modifying the mcp-server-planton repo
- Creating any files in agent-fleet besides the one tool script

