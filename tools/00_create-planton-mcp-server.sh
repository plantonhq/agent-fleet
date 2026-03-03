#!/usr/bin/env bash
# ==============================================================================
# 00_create-planton-mcp-server.sh - Generate the Planton Cloud McpServer YAML
# ==============================================================================
#
# Uses `stigmer draft mcp-server` to generate a Stigmer McpServer YAML that
# declares the Planton Cloud MCP server — an existing Go binary
# (mcp-server-planton) that bridges MCP protocol to Planton Cloud's gRPC
# backend.
#
# The Planton monorepo is provided as the workspace so the agent can freely
# explore docs/product/, apis/ai/planton/, and client-apps/cli/ for deep
# domain understanding. Key documentation directories are also explicitly
# attached as spotlight context:
#   - docs/product/infra-hub                       (Cloud Resources, Stack Jobs, Infra Charts, etc.)
#   - docs/product/service-hub                     (Services, CI/CD Pipelines, Tekton)
#   - docs/product/what-is-a-planton-api-resource.md (API resource model)
#
# Prerequisites:
#   - stigmer CLI built and available in PATH
#   - Planton monorepo cloned as a sibling (../planton relative to this repo)
#     or set PLANTON_REPO env var to override the path
#
# Usage:
#   ./tools/00_create-planton-mcp-server.sh
#
# Output:
#   Generated McpServer YAML saved to mcp-servers/
#
# ==============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ---------------------------------------------------------------------------
# Dependency checks
# ---------------------------------------------------------------------------

if ! command -v stigmer &> /dev/null; then
    echo "ERROR: stigmer CLI not found in PATH"
    echo "Install: go install github.com/stigmer/stigmer/client-apps/cli/cmd/stigmer@latest"
    exit 1
fi

# ---------------------------------------------------------------------------
# Planton monorepo resolution
# ---------------------------------------------------------------------------

if [ -n "${PLANTON_REPO:-}" ]; then
    if [ ! -d "$PLANTON_REPO" ]; then
        echo "ERROR: PLANTON_REPO is set but directory not found: $PLANTON_REPO"
        exit 1
    fi
else
    PLANTON_REPO="$(cd "$REPO_ROOT/../planton" 2>/dev/null && pwd || true)"
    if [ -z "$PLANTON_REPO" ] || [ ! -d "$PLANTON_REPO" ]; then
        echo "ERROR: Planton monorepo not found at expected sibling path: $REPO_ROOT/../planton/"
        echo "Either clone it there or set PLANTON_REPO env var to the correct path."
        exit 1
    fi
fi
readonly PLANTON_REPO

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

readonly OUTPUT_DIR="${REPO_ROOT}/mcp-servers"

readonly INFRA_HUB_DOCS="${PLANTON_REPO}/docs/product/infra-hub"
readonly SERVICE_HUB_DOCS="${PLANTON_REPO}/docs/product/service-hub"
readonly API_RESOURCE_DOC="${PLANTON_REPO}/docs/product/what-is-a-planton-api-resource.md"

for dir in "$INFRA_HUB_DOCS" "$SERVICE_HUB_DOCS"; do
    if [ ! -d "$dir" ]; then
        echo "ERROR: Directory not found: $dir"
        exit 1
    fi
done

if [ ! -f "$API_RESOURCE_DOC" ]; then
    echo "ERROR: File not found: $API_RESOURCE_DOC"
    exit 1
fi

# ---------------------------------------------------------------------------
# Prepare output
# ---------------------------------------------------------------------------

mkdir -p "$OUTPUT_DIR"

echo "=== Planton Cloud McpServer Generation ==="
echo "Workspace: ${PLANTON_REPO}"
echo "Inputs:    ${INFRA_HUB_DOCS} (Infra Hub product docs)"
echo "           ${SERVICE_HUB_DOCS} (Service Hub product docs)"
echo "           ${API_RESOURCE_DOC}"
echo "Output:    ${OUTPUT_DIR}/"
echo ""

# ---------------------------------------------------------------------------
# Draft the McpServer YAML
# ---------------------------------------------------------------------------

# Write the prompt to a temp file to avoid bash 3.2's $() + heredoc parsing
# bug, which breaks on apostrophes inside a heredoc body.
readonly _MSG_FILE="$(mktemp)"
trap 'rm -f "${_MSG_FILE}"' EXIT

cat > "${_MSG_FILE}" <<'PROMPT'
Create a Stigmer McpServer YAML for the Planton Cloud MCP server.

IMPORTANT CONTEXT: You are declaring an EXISTING MCP server binary for use
within the Stigmer platform. The server (mcp-server-planton) is already
built, published, and running in production. Your task is to create the
Stigmer McpServer YAML that describes how to connect to it, what credentials
it needs, and what operational policies to apply.

## Server Connection Details

The Planton Cloud MCP server is a stateless Go binary that translates MCP
tool calls into gRPC requests against the Planton Cloud backend. It supports
17 cloud providers and 362 resource kinds.

- **Transport**: stdio (subprocess)
- **Command**: `mcp-server-planton`
  (installed via `go install github.com/plantonhq/mcp-server-planton/cmd/mcp-server-planton@latest`
  or pre-built binary from GitHub Releases)
- **No arguments required** for the default stdio mode

### Required Environment Variables

- `PLANTON_API_KEY` — API key for Planton Cloud. Must have appropriate
  organization-level permissions. This is a secret (is_secret: true).
  Description should mention that the key is created in the Planton Console
  under Profile > API Keys > Create Key.

### Optional Environment Variables

- `PLANTON_CLOUD_ENVIRONMENT` — Target Planton environment. Values: `live`,
  `test`, or `local`. Defaults to `live`. This is NOT a secret
  (is_secret: false).

## Workspace Exploration

You are operating inside the Planton monorepo. Use this workspace access
to build deep domain understanding:

- **Start with** the attached `docs/product/what-is-a-planton-api-resource.md`
  to understand the API resource model — kinds, manifests, and the apply
  workflow.

- **Explore** the attached `docs/product/infra-hub/` for the core Infra Hub
  concepts: Cloud Resources, Cloud Resource Kinds, Stack Jobs, Infra Charts,
  Infra Projects, Infra Pipelines, Cloud Object Presets, and OpenMCF. These
  are the primary domain operations the MCP server exposes.

- **Explore** the attached `docs/product/service-hub/` for Service Hub
  concepts: Services, CI/CD Pipelines, Tekton Pipelines, and related
  resources. The MCP server also exposes tools for this domain.

- **Browse** `apis/ai/planton/` for protobuf API definitions — these define
  the exact gRPC services the MCP server calls. Key directories:
  - `apis/ai/planton/infrahub/` (cloudresource, stackjob, infrachart, infraproject, infrapipeline)
  - `apis/ai/planton/servicehub/` (service, pipeline, variablesgroup, secretsgroup)
  - `apis/ai/planton/resourcemanager/` (organization, environment)

Use this domain knowledge to write a rich, accurate `spec.description` that
captures everything this MCP server provides to AI agents.

## McpServer YAML Requirements

- `metadata.name`: `planton-cloud`
- Write a comprehensive `spec.description` that describes what this MCP server
  provides — it is the primary interface for AI agents to manage infrastructure
  and services across 17 cloud providers via Planton Cloud.
- The server covers these major tool domains:
  - Cloud Resource lifecycle (create, update, delete, destroy, lock management)
  - Stack Job observability and control (provisioning outcomes, retries)
  - Infra Chart templates (reusable infrastructure blueprints)
  - Infra Project lifecycle (chart-based or Git-based infra projects)
  - Infra Pipeline monitoring and control (deployment orchestration, gates)
  - Dependency graph (resource topology, impact analysis)
  - Config management (variables and secrets with version history)
  - Audit and version history
  - Service lifecycle (application services, Git webhook management)
  - Service CI/CD pipelines (build-and-deploy, Tekton)
  - Service variables and secrets groups
  - DNS domain management
  - Organization and environment management
  - Cloud provider credentials and connections

## Tool Defaults Policy

- `default_enabled_tools`: Leave EMPTY (do not specify any). All tools are
  available by default. Individual agents restrict to subsets via their own
  `enabled_tools` in `mcp_server_usages`.

- `default_tool_approvals`: Add approval entries for destructive operations.
  The MCP server uses snake_case tool names. Key destructive tools include:
  - `delete_cloud_resource` — "Delete cloud resource record: {{args.id}}"
  - `destroy_cloud_resource` — "Destroy infrastructure for: {{args.id}}"
  - `purge_cloud_resource` — "Purge resource and infrastructure: {{args.id}}"
  - `remove_cloud_resource_locks` — "Force-clear locks on: {{args.id}}"
  - `delete_organization` — "Delete organization: {{args.id}}"
  - `delete_environment` — "Delete environment: {{args.id}}"
  - `delete_infra_project` — "Delete infra project: {{args.id}}"
  - `undeploy_infra_project` — "Undeploy infra project: {{args.id}}"
  - `cancel_stack_job` — "Cancel running stack job: {{args.id}}"
  - `cancel_infra_pipeline` — "Cancel running infra pipeline: {{args.id}}"
  - `delete_infra_pipeline` — "Delete infra pipeline: {{args.id}}"
  - `delete_service` — "Delete service: {{args.id}}"
  - `cancel_pipeline` — "Cancel service pipeline: {{args.id}}"
  - `delete_credential` — "Delete credential: {{args.id}}"
  - `revoke_org_access` — "Revoke organization access: {{args.principal_id}}"
  - `delete_api_key` — "Delete API key: {{args.id}}"

  Include all of these in `default_tool_approvals` with clear, action-oriented
  messages using `{{args.field}}` placeholders. Keep messages under 100 chars.

## Quality Standards

This is a foundational resource for a world-class platform. The generated
McpServer YAML must be:
- Precisely conformant to the agentic.stigmer.ai/v1 McpServer schema
- Rich in its description (not a one-liner — capture the full value)
- Accurate in its env_spec declarations
- Thoughtful in its approval policies (protect against accidental destruction)
- Clean — no status section, no placeholder values for secrets
PROMPT

stigmer draft mcp-server \
  --workspace "$PLANTON_REPO" \
  --attach "$INFRA_HUB_DOCS" \
  --attach "$SERVICE_HUB_DOCS" \
  --attach "$API_RESOURCE_DOC" \
  --output "$OUTPUT_DIR" \
  --env "OUTPUT_DIR=mcp-servers" \
  --model claude-sonnet-4.6 \
  -m "$(cat "${_MSG_FILE}")"

echo ""
echo "=== Generation Complete ==="
echo "Output saved to: ${OUTPUT_DIR}/"
echo ""
echo "Next steps:"
echo "  1. Review the generated McpServer YAML in ${OUTPUT_DIR}/"
echo "  2. Validate:  stigmer apply -f ${OUTPUT_DIR}/planton-cloud.yaml --dry-run"
echo "  3. Discover:  stigmer discover mcp-server planton-cloud"
echo "  4. Verify tool names in default_tool_approvals match discovered names"
echo "  5. Apply:     stigmer apply -f ${OUTPUT_DIR}/planton-cloud.yaml"
