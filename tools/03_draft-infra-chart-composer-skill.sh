#!/usr/bin/env bash
# ==============================================================================
# 03_draft-infra-chart-composer-skill.sh
# ==============================================================================
#
# Drafts the infra-chart-composer skill using `stigmer draft skill`.
#
# The Planton monorepo is passed as a workspace so the skill-creator agent
# can explore it freely — documentation, real examples, changelogs, and
# protobuf APIs. The prompt provides intent and discovery guidance rather
# than prescriptive file paths.
#
# Prerequisites:
#   - stigmer CLI in PATH
#   - planton monorepo cloned as a sibling directory (../planton)
#
# Usage:
#   ./tools/03_draft-infra-chart-composer-skill.sh
#   ./tools/03_draft-infra-chart-composer-skill.sh /path/to/planton
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

# ---------------------------------------------------------------------------
# Locate the planton monorepo
# ---------------------------------------------------------------------------

PLANTON_REPO="${1:-${REPO_ROOT}/../planton}"

if [ ! -d "$PLANTON_REPO" ]; then
    echo "ERROR: planton monorepo not found at ${PLANTON_REPO}"
    echo ""
    echo "Clone it as a sibling directory:"
    echo "  git clone https://github.com/plantonhq/planton.git ${REPO_ROOT}/../planton"
    echo ""
    echo "Or pass the path explicitly:"
    echo "  $0 /path/to/planton"
    exit 1
fi

PLANTON_REPO="$(cd "$PLANTON_REPO" && pwd)"

# ---------------------------------------------------------------------------
# Draft the skill
# ---------------------------------------------------------------------------

echo "=== Drafting infra-chart-composer skill ==="
echo "  Planton repo : ${PLANTON_REPO}"
echo "  Agent fleet  : ${REPO_ROOT}"
echo ""

readonly _MSG_FILE="$(mktemp)"
trap 'rm -f "${_MSG_FILE}"' EXIT

cat > "${_MSG_FILE}" <<'PROMPT'
Create a Stigmer skill named "infra-chart-composer".

Write the skill to skills/infra-chart-composer/ in the agent-fleet workspace.

== WHAT THIS SKILL IS FOR ==

This skill powers an agent that is a world-class infrastructure architect
specializing in Planton InfraCharts. The agent handles the full lifecycle:

  - Compose NEW InfraCharts from natural language requirements.
  - MODIFY existing InfraCharts — add resources, remove resources, update
    parameters, restructure templates, fix dependency ordering.
  - Build correct ValueFromRef dependency chains and DAG structures.
  - Apply proper Jinjava templating, conditional logic, and parameter design.
  - Validate that every cloud resource kind used in templates has a valid spec
    schema by fetching it on-demand via the MCP server.

The agent produces FILES (Chart.yaml, values.yaml, templates/*.yaml).
Deployment is a separate step handled by the user.

== HOW TO BUILD THIS SKILL — EXPLORE THE PLANTON WORKSPACE ==

The Planton monorepo in your workspace contains everything you need to deeply
understand InfraCharts. Explore it to build your knowledge:

  - Search for "what-is-*" documentation articles. These are the authoritative
    source for how InfraHub concepts work — InfraCharts, InfraProjects,
    InfraPipelines, Cloud Resources, Cloud Resource Kinds, Cloud Objects,
    OpenMCF, Stack Jobs, presets, and more. Read all of them.

  - Find real production InfraChart examples. These are actual charts deployed
    on the platform, ranging from simple single-resource charts to complex
    multi-resource stacks. Study how they use parameters, ValueFromRef,
    conditionals, multi-document templates, provisioner labels, and
    metadata.relationships.

  - Search for InfraChart-related changelogs under _changelog/ directories.
    These are rich architectural records that explain HOW and WHY patterns
    evolved — parameter type additions, DAG improvements, chart decomposition
    strategies, cross-chart references, and more.

  - Find the protobuf API definitions for InfraChart resources. These give
    you the exact field names, types, and validation rules for Chart.yaml
    and values.yaml.

== SCHEMA DISCOVERY — CRITICAL ==

The Planton platform has 300+ cloud resource kinds. The agent cannot have all
schemas embedded. Instead, the Planton MCP server exposes two resources:

  cloud-resource-kinds://catalog — lists all kinds grouped by provider
  cloud-resource-schema://{kind} — returns the JSON schema for a specific kind

The skill MUST teach the agent to discover schemas on-demand: read the
catalog, fetch schemas for the kinds needed, and use those schemas to write
correct spec fields. Never guess field names.

== CHANGELOG-DRIVEN LEARNING ==

The skill should instruct the agent: when the Planton monorepo is available
in the workspace, search changelogs for recent InfraChart changes to learn
about new patterns or structural changes. This future-proofs the agent.

== KEY PRINCIPLES THE SKILL MUST CONVEY ==

  - Always fetch the schema before writing resource templates
  - Always include clear descriptions for every parameter
  - Always document dependencies so the DAG is explicit
  - Prefer multi-file templates organized by concern
  - When modifying existing charts, preserve existing conventions
  - When adding resources, verify DAG integration with existing resources
  - When removing resources, check for dependents that would break
  - Write a README.md for every chart
  - The agent does NOT deploy — it produces files for the user to review
PROMPT

stigmer draft skill \
    --workspace "$PLANTON_REPO" \
    --workspace "$REPO_ROOT" \
    --model claude-opus-4.6 \
    -m "$(cat "${_MSG_FILE}")"

echo ""
echo "Done. Generated:"
echo "  skills/infra-chart-composer/SKILL.md"
echo "  skills/infra-chart-composer/references/*"
echo ""
echo "Next steps:"
echo "  1. Review the generated skill"
echo "  2. Run: ./tools/04_draft-infra-chart-composer-agent.sh"
