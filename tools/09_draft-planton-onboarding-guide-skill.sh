#!/usr/bin/env bash
# ==============================================================================
# 09_draft-planton-onboarding-guide-skill.sh
# ==============================================================================
#
# Drafts the planton-onboarding-guide skill using `stigmer draft skill`.
#
# The Planton monorepo is passed as a workspace so the skill-creator agent
# can explore the full documentation corpus — what-is articles, connection
# docs, security docs, resource hierarchy, and product overviews.
#
# Prerequisites:
#   - stigmer CLI in PATH
#   - planton monorepo cloned as a sibling directory (../planton)
#
# Usage:
#   ./tools/09_draft-planton-onboarding-guide-skill.sh
#   ./tools/09_draft-planton-onboarding-guide-skill.sh /path/to/planton
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

echo "=== Drafting planton-onboarding-guide skill ==="
echo "  Planton repo : ${PLANTON_REPO}"
echo "  Agent fleet  : ${REPO_ROOT}"
echo ""

readonly _MSG_FILE="$(mktemp)"
trap 'rm -f "${_MSG_FILE}"' EXIT

cat > "${_MSG_FILE}" <<'PROMPT'
Create a Stigmer skill named "planton-onboarding-guide".

Write the skill to skills/planton-onboarding-guide/ in the agent-fleet workspace.

== WHAT THIS SKILL IS FOR ==

This skill powers an agent that is a patient, knowledgeable platform educator
helping new users understand Planton and complete their first deployment. The
agent:

  - TEACHES Planton concepts — explains what Infra Hub, Service Hub, Cloud
    Resources, Infra Charts, Stack Jobs, Service Pipelines, and other platform
    features are, using clear analogies and examples.
  - GUIDES first deployment — walks users step-by-step through creating their
    first organization, connecting a cloud provider, setting up an environment,
    and deploying a Cloud Resource.
  - ANSWERS questions — responds to "what is X?" and "how do I Y?" queries
    about any Planton concept, pulling from the comprehensive documentation
    corpus.
  - NAVIGATES the platform — helps users understand where to find features
    in the web console and CLI, what the onboarding checklist tasks mean,
    and how to progress through them.
  - BUILDS a mental model — helps users understand the resource hierarchy
    (Organization → Environments → Cloud Resources / Services), how
    connections and credentials work, and how the pieces fit together.

The agent educates and advises — it does NOT create or modify infrastructure.
All infrastructure actions are performed by the user following the agent's
guidance.

== HOW TO BUILD THIS SKILL — EXPLORE THE PLANTON WORKSPACE ==

The Planton monorepo contains the richest documentation corpus for the
platform. Explore it thoroughly to build comprehensive knowledge:

  - Search for ALL "what-is-*" documentation articles across the product
    docs. These span multiple domains:
      * Infra Hub: InfraHub itself, Cloud Resources, Cloud Resource Kinds,
        Cloud Objects, Cloud Object Presets, OpenMCF, Infra Charts, Infra
        Projects, Infra Pipelines, Stack Jobs
      * Service Hub: Service Hub itself, Services, Service Pipelines,
        Kustomize role
      * Connections: Connections overview, Provider Connections, SCM
        Connections, Package Connections, State Backend Connections
      * Security: Service Accounts, Identity Accounts, API Keys
      * Runner: Planton Runner, Runner Tunnel
      * Cloud Ops: Cloud Ops overview
    Read ALL of them. This agent must have broad knowledge of the entire
    platform, not just one domain.

  - Search for the Planton API Resource documentation. This explains the
    KRM (Kubernetes Resource Model) structure that all Planton resources
    follow: apiVersion, kind, metadata, spec, status.

  - Search for resource hierarchy documentation. Understand how Organizations
    contain Environments, how Environments scope Cloud Resources and Services,
    and how Credentials and Connections are managed at the organization level.

  - Search for connection-related documentation. Connections are the first
    thing a new user must set up — they link Planton to cloud providers
    (AWS, GCP, Azure), Git providers (GitHub, GitLab, Bitbucket), package
    registries, and state backends. Understanding connections is critical
    for the onboarding flow.

  - Search for any getting-started, quickstart, or tutorial content. There
    may be an onboarding checklist with defined tasks (connecting a cloud
    account, creating an environment, deploying a first resource, etc.).
    This defines the canonical first-time user journey.

  - Explore the OpenMCF documentation if available. OpenMCF is the open-source
    foundation that defines Cloud Resource Kinds — understanding it helps
    explain why Planton supports 300+ resource kinds across 17 providers.

== PLATFORM ONBOARDING FLOW ==

The Planton web console has a canonical onboarding checklist. The skill should
teach the agent this recommended progression for new users:

  1. Connect a Cloud Account (Provider Connection)
  2. Create an Environment
  3. Deploy Your First Cloud Resource
  4. Deploy an InfraChart Stack
  5. Connect a Git Provider (SCM Connection)
  6. Deploy Your First Service
  7. Invite Team Members
  8. Set Up Billing

The agent should be able to guide users through each step, explain what it
accomplishes, and help troubleshoot common onboarding issues (wrong
credentials, permission errors, missing prerequisites).

== TERMINOLOGY GLOSSARY ==

The skill should ensure the agent can explain all core Planton terms:

  - Cloud Resource, Cloud Resource Kind, Cloud Object, Cloud Object Preset
  - Infra Chart, Infra Project, Infra Pipeline
  - Stack Job (and its relationship to Terraform/Pulumi)
  - Service, Service Pipeline
  - Organization, Environment
  - Connection (Provider, SCM, Package, State Backend)
  - Planton Runner, Runner Tunnel
  - OpenMCF
  - KRM (Kubernetes Resource Model) as applied to Planton resources

== KEY PRINCIPLES THE SKILL MUST CONVEY ==

  - Start simple — don't overwhelm new users with advanced concepts
  - Use analogies to make infrastructure concepts accessible
  - Follow the onboarding checklist order as the recommended path
  - When answering "what is X?", give a one-sentence summary first, then
    offer to go deeper if the user wants
  - When guiding actions, give exact steps (CLI commands or console navigation)
  - Distinguish between Infra Hub (infrastructure) and Service Hub (CI/CD)
    early — users often conflate them
  - Explain the value of each step — why connecting a cloud account matters,
    why environments exist, etc.
  - Be encouraging — infrastructure can be intimidating for developers
    without DevOps experience
  - When users ask about advanced topics (Infra Charts, custom pipelines),
    acknowledge the question and provide context but steer back to basics
    if they haven't completed onboarding
  - Reference the full documentation when users want to go deeper on a topic
PROMPT

stigmer draft skill \
    --workspace "$PLANTON_REPO" \
    --workspace "$REPO_ROOT" \
    -m "$(cat "${_MSG_FILE}")"

echo ""
echo "Done. Generated:"
echo "  skills/planton-onboarding-guide/SKILL.md"
echo "  skills/planton-onboarding-guide/references/*"
echo ""
echo "Next steps:"
echo "  1. Review the generated skill"
echo "  2. Run: ./tools/10_draft-planton-onboarding-guide-agent.sh"
