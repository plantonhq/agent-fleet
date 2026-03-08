#!/usr/bin/env bash
# ==============================================================================
# 07_draft-stack-job-troubleshooter-skill.sh
# ==============================================================================
#
# Drafts the stack-job-troubleshooter skill using `stigmer draft skill`.
#
# The Planton monorepo is passed as a workspace so the skill-creator agent
# can explore it freely — Stack Job documentation, changelogs, protobuf APIs,
# and real examples. The prompt provides intent and discovery guidance rather
# than prescriptive file paths.
#
# Prerequisites:
#   - stigmer CLI in PATH
#   - planton monorepo cloned as a sibling directory (../planton)
#
# Usage:
#   ./tools/07_draft-stack-job-troubleshooter-skill.sh
#   ./tools/07_draft-stack-job-troubleshooter-skill.sh /path/to/planton
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

echo "=== Drafting stack-job-troubleshooter skill ==="
echo "  Planton repo : ${PLANTON_REPO}"
echo "  Agent fleet  : ${REPO_ROOT}"
echo ""

readonly _MSG_FILE="$(mktemp)"
trap 'rm -f "${_MSG_FILE}"' EXIT

cat > "${_MSG_FILE}" <<'PROMPT'
Create a Stigmer skill named "stack-job-troubleshooter".

Write the skill to skills/stack-job-troubleshooter/ in the agent-fleet workspace.

== WHAT THIS SKILL IS FOR ==

This skill powers an agent that is a senior SRE and infrastructure reliability
engineer specializing in diagnosing failed Planton Stack Jobs. Stack Jobs are
the execution units that run Terraform or Pulumi operations to provision and
manage cloud infrastructure. When a Stack Job fails, this agent:

  - DIAGNOSES the root cause by reading the Stack Job's status, progress
    events, per-step IaC operation states, and error messages.
  - EXPLAINS the failure in plain language — what went wrong, at which step,
    and why — so the user understands the issue without needing IaC expertise.
  - RECOMMENDS a fix: whether to retry the job, modify the Cloud Resource
    spec and reapply, fix a credential/connection issue, address a cloud
    provider quota or permission problem, or resolve a state lock.
  - GUIDES the user through the resolution — editing the resource spec,
    rerunning the job, or escalating if the issue is outside the platform's
    control (e.g., cloud provider outage, billing issue).
  - CORRELATES Stack Job errors with the Cloud Resource configuration that
    triggered the job, identifying spec fields that likely caused the failure.

The agent reads and analyzes — it does NOT auto-fix or auto-rerun. Every
mutating action requires explicit user confirmation.

== HOW TO BUILD THIS SKILL — EXPLORE THE PLANTON WORKSPACE ==

The Planton monorepo in your workspace contains everything you need to deeply
understand Stack Jobs. Explore it to build your knowledge:

  - Search for "what-is-*" documentation articles related to Stack Jobs.
    These explain the Stack Job lifecycle (creation, execution via Temporal,
    completion), operation types, essentials (IaC module, provisioner, provider
    credential, backend credential, flow control, IaC runner), real-time
    progress events, and cancellation behavior. Also read related articles
    about Cloud Resources, Infra Pipelines, and Infra Hub to understand the
    full context in which Stack Jobs execute.

  - Search for Stack Job-related changelogs under _changelog/ directories.
    There are 60+ changelog entries covering error transparency improvements,
    status synchronization, cancellation behavior, stack input error UX,
    queued state handling, CLI rich UI, and Temporal worker migrations. These
    are rich architectural records that explain HOW the system evolved and
    what edge cases were discovered.

  - Find the protobuf API definitions for Stack Jobs. These define the exact
    data model: StackJob, StackJobSpec, StackJobStatus, StackJobEssentials,
    StackJobProgressEvent, StackJobProgressIacOperationState, operation types,
    diagnostic severity, and both Terraform-specific and Pulumi-specific
    engine event payloads. Understanding the proto model is critical for
    knowing what fields the agent can inspect when diagnosing failures.

  - Note the existing getErrorResolutionRecommendation RPC — the platform
    already has an AI-assisted error recommendation endpoint. The skill should
    teach the agent about this pattern but position the agent as a more
    comprehensive troubleshooter that goes beyond single-error recommendations.

== IaC OPERATION STEP MODEL — CRITICAL ==

Stack Jobs execute through a defined sequence of IaC operations. The skill
MUST teach the agent this step model so it can pinpoint WHERE a failure
occurred:

  init → refresh → update_preview/destroy_preview → update/destroy

Each step has its own StackJobProgressIacOperationState with status, errors,
and diagnostic events. Failures at different steps have different root causes:

  - init failures: backend connectivity, provider plugin issues
  - refresh failures: state corruption, resource drift, permission issues
  - preview failures: validation errors, unsupported configurations
  - apply/destroy failures: cloud provider errors, quota limits, timeouts,
    dependency ordering, eventual consistency

== COMMON FAILURE PATTERNS ==

The skill should teach the agent to recognize and diagnose common categories:

  - State lock conflicts (another operation in progress)
  - Provider authentication failures (expired or invalid credentials)
  - Cloud provider quota/limit exceeded
  - Resource dependency failures (resource A must exist before resource B)
  - Timeout errors (long-running provisions like databases, clusters)
  - Permission/IAM errors (insufficient roles or policies)
  - Network/connectivity issues (VPC, subnet, security group conflicts)
  - Pulumi runtime errors (dependency conflicts, SDK version mismatches)
  - Terraform provider version incompatibilities

== RETRY VS FIX-AND-REAPPLY DECISION FRAMEWORK ==

The skill must teach the agent when to recommend each approach:

  - RETRY (rerun the job): transient errors, timeouts, eventual consistency
    issues, temporary quota spikes, intermittent network failures.
  - FIX-AND-REAPPLY (modify the Cloud Resource spec): validation errors,
    incorrect field values, missing required fields, wrong resource kind,
    unsupported configurations for the target provider.
  - ESCALATE: cloud provider outages, billing/account issues, platform bugs,
    state corruption requiring manual intervention.

== KEY PRINCIPLES THE SKILL MUST CONVEY ==

  - Always read the full Stack Job status before diagnosing — don't jump to
    conclusions from the error summary alone
  - Identify the exact IaC operation step where the failure occurred
  - Read the Terraform or Pulumi engine events for detailed diagnostics
  - Correlate errors with the Cloud Resource spec that triggered the job
  - Distinguish between transient and persistent failures
  - When recommending spec changes, explain what field to change and why
  - When a job is stuck in "running" state, check for cancellation options
    and explain the signal-based cancellation behavior
  - When multiple errors are present, prioritize the root cause over symptoms
  - Reference relevant documentation patterns (changelogs, what-is articles)
    when they help the user understand the broader context
  - Never auto-rerun a failed job — always explain the diagnosis first and
    let the user decide whether to retry or fix
PROMPT

stigmer draft skill \
    --workspace "$PLANTON_REPO" \
    --workspace "$REPO_ROOT" \
    --model claude-opus-4.6 \
    -m "$(cat "${_MSG_FILE}")"

echo ""
echo "Done. Generated:"
echo "  skills/stack-job-troubleshooter/SKILL.md"
echo "  skills/stack-job-troubleshooter/references/*"
echo ""
echo "Next steps:"
echo "  1. Review the generated skill"
echo "  2. Run: ./tools/08_draft-stack-job-troubleshooter-agent.sh"
