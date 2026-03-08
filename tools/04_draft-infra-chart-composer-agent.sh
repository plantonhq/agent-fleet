#!/usr/bin/env bash
# ==============================================================================
# 04_draft-infra-chart-composer-agent.sh
# ==============================================================================
#
# Drafts the infra-chart-composer agent YAML using `stigmer draft agent`.
#
# The agent-fleet repo is passed as the workspace so the agent-creator can
# read the generated skill and the MCP server definition, then determine
# the right wiring from discovered capabilities.
#
# Prerequisites:
#   - stigmer CLI in PATH
#   - skills/infra-chart-composer/SKILL.md exists (from step 03)
#   - mcp-servers/mcp-server-planton.yaml exists (from step 00)
#
# Usage:
#   ./tools/04_draft-infra-chart-composer-agent.sh
#
# ==============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ---------------------------------------------------------------------------
# Dependency checks
# ---------------------------------------------------------------------------

if ! command -v stigmer &>/dev/null; then
    echo "ERROR: stigmer CLI not found in PATH"
    echo "Install: go install github.com/stigmer/stigmer/client-apps/cli/cmd/stigmer@latest"
    exit 1
fi

if [ ! -f "${REPO_ROOT}/skills/infra-chart-composer/SKILL.md" ]; then
    echo "ERROR: skills/infra-chart-composer/SKILL.md not found"
    echo "Run ./tools/03_draft-infra-chart-composer-skill.sh first."
    exit 1
fi

if [ ! -f "${REPO_ROOT}/mcp-servers/mcp-server-planton.yaml" ]; then
    echo "ERROR: mcp-servers/mcp-server-planton.yaml not found"
    echo "Run ./tools/00_onboard-planton-mcp-server.sh first."
    exit 1
fi

# ---------------------------------------------------------------------------
# Draft the agent
# ---------------------------------------------------------------------------

echo "=== Drafting infra-chart-composer agent ==="
echo "  Agent fleet : ${REPO_ROOT}"
echo ""

readonly _MSG_FILE="$(mktemp)"
trap 'rm -f "${_MSG_FILE}"' EXIT

cat > "${_MSG_FILE}" <<'PROMPT'
Create a Stigmer Agent YAML named "infra-chart-composer".

Write the agent to agents/infra-chart-composer.yaml in this workspace.

== DISCOVERY — READ THE WORKSPACE ==

Read the MCP server definition under mcp-servers/ to understand what server
to reference. Read the generated skill under skills/infra-chart-composer/ to
understand the domain knowledge this agent uses.

Look up the MCP server's discovered capabilities to see all available tools.
Based on the agent's role below, select ONLY the tools that are appropriate.
This agent composes YAML files — it does NOT deploy or mutate infrastructure.
Choose tools accordingly.

== AGENT ROLE ==

This agent is an expert infrastructure architect that composes, modifies, and
validates Planton InfraCharts. It:

  - Creates new InfraCharts from natural language requirements
  - Modifies existing InfraCharts (add/remove resources, update params)
  - Builds correct dependency graphs (ValueFromRef, DAG ordering)
  - Fetches cloud resource schemas on-demand for 300+ resource kinds
  - Produces Chart.yaml, values.yaml, templates/, and README.md files
  - Does NOT deploy — output is files for the user to review and apply

The system prompt should reflect this role — a principal infrastructure
architect who thinks carefully about dependencies, validates against schemas,
and explains the architecture to the user.
PROMPT

stigmer draft agent \
    --workspace "$REPO_ROOT" \
    --model claude-opus-4.6 \
    -m "$(cat "${_MSG_FILE}")"

echo ""
echo "Done. Generated:"
echo "  agents/infra-chart-composer.yaml"
echo ""
echo "Next steps:"
echo "  1. Review agents/infra-chart-composer.yaml"
echo "  2. Apply: stigmer apply -f agents/infra-chart-composer.yaml"
