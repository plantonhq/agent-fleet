#!/usr/bin/env bash
# ==============================================================================
# 01_generate-approval-policy.sh
# ==============================================================================
#
# Applies the Planton McpServer YAML (triggering auto-discovery of
# tools and resources), then uses `stigmer draft mcp-server` to generate
# default_tool_approvals based on the discovered capabilities.
#
# The mcp-server-creator agent queries the backend for the planton
# MCP server's discovered tools and determines which operations need human
# approval based on the nature of each tool.
#
# Prerequisites:
#   - stigmer CLI in PATH
#   - mcp-servers/planton.yaml exists (from 00_onboard-planton-mcp-server.sh)
#   - PLANTON_API_KEY configured for discovery to connect to the server
#
# Usage:
#   ./tools/01_generate-approval-policy.sh
#
# ==============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly OUTPUT_DIR="${REPO_ROOT}/mcp-servers"
readonly MCP_SERVER_YAML="${OUTPUT_DIR}/planton.yaml"

# ---------------------------------------------------------------------------
# Dependency checks
# ---------------------------------------------------------------------------

if ! command -v stigmer &>/dev/null; then
    echo "ERROR: stigmer CLI not found in PATH"
    echo "Install: go install github.com/stigmer/stigmer/client-apps/cli/cmd/stigmer@latest"
    exit 1
fi

if [ ! -f "$MCP_SERVER_YAML" ]; then
    echo "ERROR: McpServer YAML not found: ${MCP_SERVER_YAML}"
    echo "Run ./tools/00_onboard-planton-mcp-server.sh first."
    exit 1
fi

# ---------------------------------------------------------------------------
# Apply the McpServer (triggers auto-discovery)
# ---------------------------------------------------------------------------

echo "=== Applying McpServer YAML ==="
echo "File: ${MCP_SERVER_YAML}"
echo ""

stigmer apply -f "$MCP_SERVER_YAML"

# ---------------------------------------------------------------------------
# Generate approval policies from discovered capabilities
# ---------------------------------------------------------------------------

echo ""
echo "=== Generating Approval Policies ==="
echo ""

readonly _MSG_FILE="$(mktemp)"
trap 'rm -f "${_MSG_FILE}"' EXIT

cat > "${_MSG_FILE}" <<'PROMPT'
Generate an updated planton McpServer YAML with default_tool_approvals.

Look up the discovered capabilities of the planton MCP server.
Based on the nature of each tool, identify destructive or dangerous operations
and add default_tool_approvals with clear approval messages.

Output only apiVersion, kind, metadata, and spec. Do not include status.
PROMPT

stigmer draft mcp-server \
    --output "$OUTPUT_DIR" \
    -m "$(cat "${_MSG_FILE}")"

echo ""
echo "=== Approval Policy Generation Complete ==="
echo "Output: ${OUTPUT_DIR}/"
echo ""
echo "Next steps:"
echo "  1. Review the updated McpServer YAML with approval policies"
echo "  2. Apply: stigmer apply -f ${MCP_SERVER_YAML}"
