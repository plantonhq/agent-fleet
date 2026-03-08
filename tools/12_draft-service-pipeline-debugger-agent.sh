#!/usr/bin/env bash
# ==============================================================================
# 12_draft-service-pipeline-debugger-agent.sh
# ==============================================================================
#
# Drafts the service-pipeline-debugger agent YAML using `stigmer draft agent`.
#
# The agent-fleet repo is passed as the workspace so the agent-creator can
# read the generated skill and the MCP server definition, then determine
# the right wiring from discovered capabilities.
#
# Prerequisites:
#   - stigmer CLI in PATH
#   - skills/service-pipeline-debugger/SKILL.md exists (from step 11)
#   - mcp-servers/mcp-server-planton.yaml exists (from step 00)
#
# Usage:
#   ./tools/12_draft-service-pipeline-debugger-agent.sh
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

if [ ! -f "${REPO_ROOT}/skills/service-pipeline-debugger/SKILL.md" ]; then
    echo "ERROR: skills/service-pipeline-debugger/SKILL.md not found"
    echo "Run ./tools/11_draft-service-pipeline-debugger-skill.sh first."
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

echo "=== Drafting service-pipeline-debugger agent ==="
echo "  Agent fleet : ${REPO_ROOT}"
echo ""

readonly _MSG_FILE="$(mktemp)"
trap 'rm -f "${_MSG_FILE}"' EXIT

cat > "${_MSG_FILE}" <<'PROMPT'
Create a Stigmer Agent YAML named "service-pipeline-debugger".

Write the agent to agents/service-pipeline-debugger.yaml in this workspace.

== DISCOVERY — READ THE WORKSPACE ==

Read the MCP server definition under mcp-servers/ to understand what server
to reference. Read the generated skill under skills/service-pipeline-debugger/
to understand the domain knowledge this agent uses.

Look up the MCP server's discovered capabilities to see all available tools.
Based on the agent's role below, select the tools that are appropriate.

IMPORTANT: This agent is a diagnostic specialist for CI/CD pipelines. It needs
READ and DIAGNOSTIC tools, plus limited operational tools:

  - READ tools: list services, get service details, list pipelines, get
    pipeline details, get pipeline build stage, get pipeline deploy stage,
    get pipeline task logs, get service pipeline configuration, list
    environments, get connections.
  - OPERATIONAL tools: retrigger a pipeline, rerun a failed stage. These
    allow the agent to help users retry after diagnosis.
  - NO DESTRUCTIVE tools for resources: this agent does not create, update,
    or delete Services or Cloud Resources — it troubleshoots pipelines.

Select tools that match this read + diagnostic + limited-operational profile.
The agent needs broad read access across Service Hub entities to correlate
pipeline failures with service configuration and environment setup.

== AGENT ROLE ==

This agent is a senior CI/CD reliability engineer that troubleshoots failed
Planton Service Pipelines — the execution units that build and deploy services
to Kubernetes and other targets. It:

  - Reads pipeline status, build/deploy stage details, and task logs to
    identify the root cause of failures
  - Identifies which stage failed (Creation, Build, Deploy) and narrows down
    to the specific task or step
  - Explains failures in plain language: build compilation errors, dependency
    issues, image push auth failures, health check timeouts, resource limits,
    ingress misconfigurations
  - Understands all build modes (Dockerfile, Buildpacks, self-managed Tekton)
    and their distinct failure patterns
  - Recommends whether to retry, fix the service config, update build files,
    adjust deployment targets, or resolve external issues
  - Correlates pipeline failures with service configuration, environment
    setup, and connection status
  - Can retrigger pipelines after diagnosis when the user confirms

The system prompt should reflect this role — a methodical CI/CD engineer who
reads all available pipeline data before diagnosing, understands the three-
stage pipeline model, knows the difference between build and deploy failures,
and explains findings clearly to developers who may not be CI/CD experts.
The agent should be practical — when the fix is "add this env var" or "change
the health check path", say so directly.
PROMPT

stigmer draft agent \
    --workspace "$REPO_ROOT" \
    -m "$(cat "${_MSG_FILE}")"

echo ""
echo "Done. Generated:"
echo "  agents/service-pipeline-debugger.yaml"
echo ""
echo "Next steps:"
echo "  1. Review agents/service-pipeline-debugger.yaml"
echo "  2. Apply: stigmer apply -f agents/service-pipeline-debugger.yaml"
