#!/usr/bin/env bash
# ==============================================================================
# 06_draft-cloud-resource-assistant-agent.sh
# ==============================================================================
#
# Drafts the cloud-resource-assistant agent YAML using `stigmer draft agent`.
#
# The agent-fleet repo is passed as the workspace so the agent-creator can
# read the generated skill and the MCP server definition, then determine
# the right wiring from discovered capabilities.
#
# Prerequisites:
#   - stigmer CLI in PATH
#   - skills/cloud-resource-assistant/SKILL.md exists (from step 05)
#   - mcp-servers/mcp-server-planton.yaml exists (from step 00)
#
# Usage:
#   ./tools/06_draft-cloud-resource-assistant-agent.sh
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

if [ ! -f "${REPO_ROOT}/skills/cloud-resource-assistant/SKILL.md" ]; then
    echo "ERROR: skills/cloud-resource-assistant/SKILL.md not found"
    echo "Run ./tools/05_draft-cloud-resource-assistant-skill.sh first."
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

echo "=== Drafting cloud-resource-assistant agent ==="
echo "  Agent fleet : ${REPO_ROOT}"
echo ""

readonly _MSG_FILE="$(mktemp)"
trap 'rm -f "${_MSG_FILE}"' EXIT

cat > "${_MSG_FILE}" <<'PROMPT'
Create a Stigmer Agent YAML named "cloud-resource-assistant".

Write the agent to agents/cloud-resource-assistant.yaml in this workspace.

== DISCOVERY — READ THE WORKSPACE ==

Read the MCP server definition under mcp-servers/ to understand what server
to reference. Read the generated skill under skills/cloud-resource-assistant/
to understand the domain knowledge this agent uses.

Look up the MCP server's discovered capabilities to see all available tools.
Based on the agent's role below, select the tools that are appropriate.

IMPORTANT: Unlike agents that only compose files, this agent actively helps
users manage the Cloud Resource lifecycle. It needs BOTH read AND write tools:

  - READ tools: list resources, get resource details, get schemas, get presets,
    list kinds, list organizations, list environments, get stack job status.
  - WRITE tools: create resources, update resources, apply manifests. These
    enable the agent to carry out user-confirmed actions.
  - DESTRUCTIVE tools (delete, destroy, force-unlock) should still require
    human approval via the MCP server's approval policy — do NOT exclude them,
    but ensure they are covered by tool_approvals.

Select tools that match this read+write profile. Do not limit the agent to
read-only tools.

== AGENT ROLE ==

This agent is a senior cloud infrastructure specialist that helps users
create, configure, and deploy any of Planton's 300+ Cloud Resource kinds.
It:

  - Turns natural language requirements into validated Cloud Resource manifests
  - Fetches and uses Cloud Object Presets as starting points
  - Fetches cloud resource schemas on-demand to validate spec fields
  - Guides users through the `planton apply` deployment workflow
  - Modifies existing resources — updates specs, scales parameters, switches
    environments
  - Explains trade-offs (cost, complexity, availability) when multiple
    approaches are possible
  - Always confirms before any destructive action

The system prompt should reflect this role — a patient, knowledgeable cloud
infrastructure specialist who guides users step-by-step, always validates
against schemas, explains what each action will do, and never proceeds with
destructive operations without explicit confirmation.
PROMPT

stigmer draft agent \
    --workspace "$REPO_ROOT" \
    --model claude-opus-4.6 \
    -m "$(cat "${_MSG_FILE}")"

echo ""
echo "Done. Generated:"
echo "  agents/cloud-resource-assistant.yaml"
echo ""
echo "Next steps:"
echo "  1. Review agents/cloud-resource-assistant.yaml"
echo "  2. Apply: stigmer apply -f agents/cloud-resource-assistant.yaml"
