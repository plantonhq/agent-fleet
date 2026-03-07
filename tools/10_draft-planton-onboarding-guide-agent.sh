#!/usr/bin/env bash
# ==============================================================================
# 10_draft-planton-onboarding-guide-agent.sh
# ==============================================================================
#
# Drafts the planton-onboarding-guide agent YAML using `stigmer draft agent`.
#
# The agent-fleet repo is passed as the workspace so the agent-creator can
# read the generated skill and the MCP server definition, then determine
# the right wiring from discovered capabilities.
#
# Prerequisites:
#   - stigmer CLI in PATH
#   - skills/planton-onboarding-guide/SKILL.md exists (from step 09)
#   - mcp-servers/planton.yaml exists (from step 00)
#
# Usage:
#   ./tools/10_draft-planton-onboarding-guide-agent.sh
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

if [ ! -f "${REPO_ROOT}/skills/planton-onboarding-guide/SKILL.md" ]; then
    echo "ERROR: skills/planton-onboarding-guide/SKILL.md not found"
    echo "Run ./tools/09_draft-planton-onboarding-guide-skill.sh first."
    exit 1
fi

if [ ! -f "${REPO_ROOT}/mcp-servers/planton.yaml" ]; then
    echo "ERROR: mcp-servers/planton.yaml not found"
    echo "Run ./tools/00_onboard-planton-mcp-server.sh first."
    exit 1
fi

# ---------------------------------------------------------------------------
# Draft the agent
# ---------------------------------------------------------------------------

echo "=== Drafting planton-onboarding-guide agent ==="
echo "  Agent fleet : ${REPO_ROOT}"
echo ""

readonly _MSG_FILE="$(mktemp)"
trap 'rm -f "${_MSG_FILE}"' EXIT

cat > "${_MSG_FILE}" <<'PROMPT'
Create a Stigmer Agent YAML named "planton-onboarding-guide".

Write the agent to agents/planton-onboarding-guide.yaml in this workspace.

== DISCOVERY — READ THE WORKSPACE ==

Read the MCP server definition under mcp-servers/ to understand what server
to reference. Read the generated skill under skills/planton-onboarding-guide/
to understand the domain knowledge this agent uses.

Look up the MCP server's discovered capabilities to see all available tools.
Based on the agent's role below, select ONLY the tools that are appropriate.

IMPORTANT: This agent is an educator and guide. It needs READ-ONLY tools to
look up platform state for contextual answers:

  - READ tools: list organizations, list environments, list cloud resource
    kinds, list connections, get cloud resource details, get infra chart
    details, get service details. These let the agent answer questions like
    "what environments do I have?" or "what resource kinds can I deploy?"
  - NO WRITE tools: this agent does not create, update, or delete any
    resources. All infrastructure actions are performed by the user following
    the agent's step-by-step guidance.
  - NO DESTRUCTIVE tools: exclude delete, destroy, cancel, and force-unlock.

Select tools that match this strictly read-only profile. The agent's value
comes from its knowledge and guidance, not from executing actions.

== AGENT ROLE ==

This agent is a patient, knowledgeable platform educator that helps new users
understand Planton and complete their first deployment. It:

  - Explains any Planton concept clearly, with analogies and examples
  - Walks users through the onboarding checklist step-by-step
  - Answers "what is X?" and "how do I Y?" questions about the platform
  - Helps users navigate the web console and CLI
  - Looks up real platform state (orgs, envs, connections) to give contextual
    answers rather than generic ones
  - Distinguishes between Infra Hub and Service Hub for new users
  - Steers users toward the recommended onboarding progression
  - Celebrates milestones ("You've deployed your first Cloud Resource!")

The system prompt should reflect this role — a friendly, encouraging platform
guide who starts simple, avoids jargon unless explaining it, gives concrete
next steps, and builds the user's confidence with infrastructure. Think of
the best developer advocate you've met — that's this agent's personality.
PROMPT

stigmer draft agent \
    --workspace "$REPO_ROOT" \
    -m "$(cat "${_MSG_FILE}")"

echo ""
echo "Done. Generated:"
echo "  agents/planton-onboarding-guide.yaml"
echo ""
echo "Next steps:"
echo "  1. Review agents/planton-onboarding-guide.yaml"
echo "  2. Apply: stigmer apply -f agents/planton-onboarding-guide.yaml"
