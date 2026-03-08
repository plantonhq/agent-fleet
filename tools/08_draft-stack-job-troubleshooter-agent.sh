#!/usr/bin/env bash
# ==============================================================================
# 08_draft-stack-job-troubleshooter-agent.sh
# ==============================================================================
#
# Drafts the stack-job-troubleshooter agent YAML using `stigmer draft agent`.
#
# The agent-fleet repo is passed as the workspace so the agent-creator can
# read the generated skill and the MCP server definition, then determine
# the right wiring from discovered capabilities.
#
# Prerequisites:
#   - stigmer CLI in PATH
#   - skills/stack-job-troubleshooter/SKILL.md exists (from step 07)
#   - mcp-servers/mcp-server-planton.yaml exists (from step 00)
#
# Usage:
#   ./tools/08_draft-stack-job-troubleshooter-agent.sh
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

if [ ! -f "${REPO_ROOT}/skills/stack-job-troubleshooter/SKILL.md" ]; then
    echo "ERROR: skills/stack-job-troubleshooter/SKILL.md not found"
    echo "Run ./tools/07_draft-stack-job-troubleshooter-skill.sh first."
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

echo "=== Drafting stack-job-troubleshooter agent ==="
echo "  Agent fleet : ${REPO_ROOT}"
echo ""

readonly _MSG_FILE="$(mktemp)"
trap 'rm -f "${_MSG_FILE}"' EXIT

cat > "${_MSG_FILE}" <<'PROMPT'
Create a Stigmer Agent YAML named "stack-job-troubleshooter".

Write the agent to agents/stack-job-troubleshooter.yaml in this workspace.

== DISCOVERY — READ THE WORKSPACE ==

Read the MCP server definition under mcp-servers/ to understand what server
to reference. Read the generated skill under skills/stack-job-troubleshooter/
to understand the domain knowledge this agent uses.

Look up the MCP server's discovered capabilities to see all available tools.
Based on the agent's role below, select the tools that are appropriate.

IMPORTANT: This agent is a diagnostic specialist. It needs READ and DIAGNOSTIC
tools, plus limited operational tools:

  - READ tools: get stack jobs, list stack jobs, get stack job progress events,
    get stack job status, get IaC resources for a job, get stack input, get
    error resolution recommendations, get cloud resource details.
  - OPERATIONAL tools: rerun a stack job, resume a stuck job. These allow the
    agent to help users retry after diagnosis.
  - DESTRUCTIVE tools: cancel a stack job. This should require human approval
    via the MCP server's approval policy — do NOT exclude it, but ensure it
    is covered by tool_approvals.

This agent does NOT need tools for creating, updating, or deleting Cloud
Resources — it troubleshoots Stack Jobs, not resource lifecycle. Select tools
that match this read + diagnostic + limited-operational profile.

== AGENT ROLE ==

This agent is a senior SRE and infrastructure reliability engineer that
diagnoses failed Planton Stack Jobs — the execution units that run Terraform
or Pulumi operations to provision cloud infrastructure. It:

  - Reads Stack Job status, progress events, and per-step IaC operation states
    to identify the root cause of failures
  - Explains failures in plain language so users without IaC expertise can
    understand what went wrong
  - Recommends whether to retry the job, fix the Cloud Resource spec, or
    escalate the issue
  - Correlates Stack Job errors with the Cloud Resource configuration that
    triggered the job
  - Guides users through resolution step-by-step
  - Can rerun jobs after diagnosis when the user confirms

The system prompt should reflect this role — a calm, methodical SRE who
reads all available diagnostic data before drawing conclusions, explains
findings clearly, distinguishes transient from persistent failures, and
never auto-reruns a job without the user's explicit confirmation.
PROMPT

stigmer draft agent \
    --workspace "$REPO_ROOT" \
    --model claude-opus-4.6 \
    -m "$(cat "${_MSG_FILE}")"

echo ""
echo "Done. Generated:"
echo "  agents/stack-job-troubleshooter.yaml"
echo ""
echo "Next steps:"
echo "  1. Review agents/stack-job-troubleshooter.yaml"
echo "  2. Apply: stigmer apply -f agents/stack-job-troubleshooter.yaml"
