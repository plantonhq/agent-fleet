#!/usr/bin/env bash
# ==============================================================================
# 00_onboard-planton-mcp-server.sh
# ==============================================================================
#
# Drafts the Planton Cloud McpServer YAML using `stigmer draft mcp-server`.
#
# The script resolves the latest version tag from the mcp-server-planton
# remote and pins the `go run` command to that exact version — never @latest.
# Two workspaces are passed so the agent can read source files directly
# without spawning subagents or running shell commands:
#   1. mcp-server-planton — source code (README, go.mod, cmd/, internal/)
#   2. agent-fleet (this repo) — output directory and existing configs
#
# Prerequisites:
#   - stigmer CLI in PATH
#   - mcp-server-planton cloned as a sibling directory (../mcp-server-planton)
#
# Usage:
#   ./tools/00_onboard-planton-mcp-server.sh
#   ./tools/00_onboard-planton-mcp-server.sh /path/to/mcp-server-planton
#
# ==============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly OUTPUT_DIR="${REPO_ROOT}/mcp-servers"
readonly MCP_SERVER_REMOTE="https://github.com/plantonhq/mcp-server-planton.git"
readonly GO_MODULE="github.com/plantonhq/mcp-server-planton/cmd/mcp-server-planton"

# ---------------------------------------------------------------------------
# Dependency checks
# ---------------------------------------------------------------------------

if ! command -v stigmer &>/dev/null; then
    echo "ERROR: stigmer CLI not found in PATH"
    echo "Install: go install github.com/stigmer/stigmer/client-apps/cli/cmd/stigmer@latest"
    exit 1
fi

# ---------------------------------------------------------------------------
# Locate the mcp-server-planton source
# ---------------------------------------------------------------------------

MCP_SERVER_LOCAL="${1:-${REPO_ROOT}/../mcp-server-planton}"

if [ ! -d "$MCP_SERVER_LOCAL" ]; then
    echo "ERROR: mcp-server-planton not found at ${MCP_SERVER_LOCAL}"
    echo ""
    echo "Clone it as a sibling directory:"
    echo "  git clone ${MCP_SERVER_REMOTE} ${REPO_ROOT}/../mcp-server-planton"
    echo ""
    echo "Or pass the path explicitly:"
    echo "  $0 /path/to/mcp-server-planton"
    exit 1
fi

MCP_SERVER_LOCAL="$(cd "$MCP_SERVER_LOCAL" && pwd)"

# ---------------------------------------------------------------------------
# Fetch latest version tag
# ---------------------------------------------------------------------------

echo "Fetching latest tag from ${MCP_SERVER_REMOTE}..."

LATEST_TAG=$(git ls-remote --tags --refs --sort=-v:refname "$MCP_SERVER_REMOTE" \
    | head -1 \
    | awk '{print $2}' \
    | sed 's|refs/tags/||')

if [ -z "$LATEST_TAG" ]; then
    echo "ERROR: No tags found in ${MCP_SERVER_REMOTE}"
    exit 1
fi

echo "Resolved version: ${LATEST_TAG}"

# ---------------------------------------------------------------------------
# Draft the McpServer YAML
# ---------------------------------------------------------------------------

mkdir -p "$OUTPUT_DIR"

echo ""
echo "=== Planton Cloud McpServer Onboarding ==="
echo "Version:    ${LATEST_TAG}"
echo "Workspaces: ${MCP_SERVER_LOCAL}"
echo "            ${REPO_ROOT}"
echo "Output:     ${OUTPUT_DIR}/"
echo ""

readonly _MSG_FILE="$(mktemp)"
trap 'rm -f "${_MSG_FILE}"' EXIT

cat > "${_MSG_FILE}" <<PROMPT
Create a Stigmer McpServer YAML named "planton-cloud".

Transport: stdio using go run with a pinned version tag.
  command: go
  args: ["run", "${GO_MODULE}@${LATEST_TAG}"]

The source code for this MCP server is available in your workspace.
Read these files to understand what it does and what it needs:
  - README.md for overview, features, and environment variables
  - go.mod for the module path and dependencies
  - cmd/ for the entrypoint and CLI flags
  - internal/ or pkg/ for tool implementations and capabilities

Write an accurate description and env_spec based on what you find.
Do not include default_tool_approvals — those will be generated after discovery.
PROMPT

stigmer draft mcp-server \
    --workspace "$MCP_SERVER_LOCAL" \
    --workspace "$REPO_ROOT" \
    --output "$OUTPUT_DIR" \
    -m "$(cat "${_MSG_FILE}")"

echo ""
echo "=== Onboarding Complete ==="
echo "Output: ${OUTPUT_DIR}/"
echo ""
echo "Next steps:"
echo "  1. Review the generated McpServer YAML"
echo "  2. Run: ./tools/01_generate-approval-policy.sh"
