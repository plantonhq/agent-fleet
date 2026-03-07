#!/usr/bin/env bash
# ==============================================================================
# 05_draft-cloud-resource-assistant-skill.sh
# ==============================================================================
#
# Drafts the cloud-resource-assistant skill using `stigmer draft skill`.
#
# The Planton monorepo is passed as a workspace so the skill-creator agent
# can explore it freely — documentation, real Cloud Resource examples,
# changelogs, and protobuf APIs. The prompt provides intent and discovery
# guidance rather than prescriptive file paths.
#
# Prerequisites:
#   - stigmer CLI in PATH
#   - planton monorepo cloned as a sibling directory (../planton)
#
# Usage:
#   ./tools/05_draft-cloud-resource-assistant-skill.sh
#   ./tools/05_draft-cloud-resource-assistant-skill.sh /path/to/planton
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

echo "=== Drafting cloud-resource-assistant skill ==="
echo "  Planton repo : ${PLANTON_REPO}"
echo "  Agent fleet  : ${REPO_ROOT}"
echo ""

readonly _MSG_FILE="$(mktemp)"
trap 'rm -f "${_MSG_FILE}"' EXIT

cat > "${_MSG_FILE}" <<'PROMPT'
Create a Stigmer skill named "cloud-resource-assistant".

Write the skill to skills/cloud-resource-assistant/ in the agent-fleet workspace.

== WHAT THIS SKILL IS FOR ==

This skill powers an agent that is a senior cloud infrastructure specialist
helping users create, configure, and deploy any of Planton's 300+ Cloud
Resource kinds from natural language. The agent handles the full lifecycle:

  - CREATE new Cloud Resources from natural language requirements.
    ("Deploy a production PostgreSQL on Kubernetes with 3 replicas and 100Gi
    storage" → a validated, deployable YAML manifest.)
  - MODIFY existing Cloud Resources — update specs, change configurations,
    scale parameters, switch environments.
  - VALIDATE specs against the authoritative JSON schema for each resource
    kind, fetched on-demand from the MCP server.
  - GUIDE users through the deployment workflow via `planton apply`, explaining
    what will happen at each step, but always letting the user decide when to
    proceed.
  - Use Cloud Object Presets as starting points — fetch presets for a given
    resource kind and customize them to the user's requirements rather than
    building from scratch.

The agent produces YAML manifests and advises on deployment. It does NOT
auto-deploy — every mutating action requires explicit user confirmation.

== HOW TO BUILD THIS SKILL — EXPLORE THE PLANTON WORKSPACE ==

The Planton monorepo in your workspace contains everything you need to deeply
understand Cloud Resources. Explore it to build your knowledge:

  - Search for "what-is-*" documentation articles. These are the authoritative
    source for how InfraHub concepts work — Cloud Resources, Cloud Resource
    Kinds, Cloud Objects, Cloud Object Presets, OpenMCF, and more. Read all
    of them that relate to Cloud Resources and their supporting concepts.

  - Find real production Cloud Resource YAML manifests. These are actual
    deployed configurations across multiple cloud providers (AWS, GCP, Azure,
    Kubernetes). Study the KRM structure: apiVersion, kind, metadata (name,
    org, environment, labels), spec (the cloud-object payload), and status.
    Pay attention to how different providers and resource kinds are structured.

  - Search for Cloud Resource-related changelogs under _changelog/ directories.
    These are rich architectural records that explain HOW and WHY patterns
    evolved — wizard improvements, preset CLI commands, spec validation
    changes, connection lookups, default resolution, and more.

  - Find the protobuf API definitions for CloudResource, CloudResourceSpec,
    CloudObjectPreset, and CloudResourceKind. These give you the exact field
    names, types, validation rules, and RPC operations available.

  - Explore the OpenMCF repository if available in the workspace. It contains
    the CloudResourceKind enum (all 300+ kinds) and the CloudResourceProvider
    enum. This is the open-source foundation that defines the resource model.

== SCHEMA DISCOVERY — CRITICAL ==

The Planton platform has 300+ cloud resource kinds across 17 cloud providers.
The agent cannot have all schemas embedded. Instead, the Planton MCP server
exposes two resources:

  cloud-resource-kinds://catalog — lists all kinds grouped by provider
  cloud-resource-schema://{kind} — returns the JSON schema for a specific kind

The skill MUST teach the agent to discover schemas on-demand:

  1. Read the catalog to find the correct kind for what the user wants.
  2. Fetch the JSON schema for that kind.
  3. Use the schema to write correct spec fields — never guess field names
     or types.
  4. Validate the completed manifest against the schema before presenting
     it to the user.

== CLOUD OBJECT PRESETS — STARTING POINTS ==

Cloud Object Presets are pre-built, validated spec configurations for common
deployment patterns. The agent should:

  - Fetch available presets for the target resource kind via the MCP server.
  - Present presets to the user as starting points when creating new resources.
  - Customize the preset based on the user's specific requirements.
  - When no preset fits, build the spec from scratch using the fetched schema.

The skill should teach this "preset-first" workflow: always check for presets
before building from scratch.

== RESOURCE IDENTITY — ID PATTERNS ==

Every Cloud Resource has a unique ID following the pattern:

  <kind-prefix>-<org>-<name>

The total length must not exceed 27 characters. The kind-prefix is determined
by the Cloud Resource Kind. The skill must teach the agent how IDs are
constructed so it can generate valid ones and warn users about length limits.

== CHANGELOG-DRIVEN LEARNING ==

The skill should instruct the agent: when the Planton monorepo is available
in the workspace, search changelogs for recent Cloud Resource changes to learn
about new patterns, validation rules, wizard improvements, or structural
changes. This future-proofs the agent.

== KEY PRINCIPLES THE SKILL MUST CONVEY ==

  - Always fetch the schema before writing any spec fields
  - Always check for presets before building from scratch
  - Always validate the manifest against the fetched schema
  - Always explain what `planton apply` will do before the user runs it
  - Always confirm before any destructive action (delete, destroy, force-unlock)
  - Generate valid resource IDs within the 27-character limit
  - Respect the KRM structure: apiVersion, kind, metadata, spec
  - Use the correct apiVersion for each resource kind
  - When modifying existing resources, preserve fields the user didn't ask
    to change
  - When the user's request is ambiguous about the cloud provider, ask for
    clarification rather than assuming
  - Explain trade-offs (cost, complexity, availability) when multiple
    approaches are possible
PROMPT

stigmer draft skill \
    --workspace "$PLANTON_REPO" \
    --workspace "$REPO_ROOT" \
    -m "$(cat "${_MSG_FILE}")"

echo ""
echo "Done. Generated:"
echo "  skills/cloud-resource-assistant/SKILL.md"
echo "  skills/cloud-resource-assistant/references/*"
echo ""
echo "Next steps:"
echo "  1. Review the generated skill"
echo "  2. Run: ./tools/06_draft-cloud-resource-assistant-agent.sh"
