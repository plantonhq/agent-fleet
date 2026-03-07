#!/usr/bin/env bash
# ==============================================================================
# 11_draft-service-pipeline-debugger-skill.sh
# ==============================================================================
#
# Drafts the service-pipeline-debugger skill using `stigmer draft skill`.
#
# The Planton monorepo is passed as a workspace so the skill-creator agent
# can explore it freely — Service Hub documentation, pipeline changelogs,
# Tekton pipeline/task protos, and self-managed pipeline guides.
#
# Prerequisites:
#   - stigmer CLI in PATH
#   - planton monorepo cloned as a sibling directory (../planton)
#
# Usage:
#   ./tools/11_draft-service-pipeline-debugger-skill.sh
#   ./tools/11_draft-service-pipeline-debugger-skill.sh /path/to/planton
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

echo "=== Drafting service-pipeline-debugger skill ==="
echo "  Planton repo : ${PLANTON_REPO}"
echo "  Agent fleet  : ${REPO_ROOT}"
echo ""

readonly _MSG_FILE="$(mktemp)"
trap 'rm -f "${_MSG_FILE}"' EXIT

cat > "${_MSG_FILE}" <<'PROMPT'
Create a Stigmer skill named "service-pipeline-debugger".

Write the skill to skills/service-pipeline-debugger/ in the agent-fleet workspace.

== WHAT THIS SKILL IS FOR ==

This skill powers an agent that is a senior CI/CD reliability engineer
specializing in troubleshooting failed Planton Service Pipelines. Service
Pipelines are the CI/CD execution units that build container images (or
Cloudflare Worker scripts) and deploy services to Kubernetes or other targets.
When a pipeline fails, this agent:

  - DIAGNOSES the root cause by reading pipeline status, build stage details,
    deploy stage details, task logs, and failure analysis data.
  - IDENTIFIES which stage failed — Creation, Build, or Deploy — and narrows
    down to the specific task or step within that stage.
  - EXPLAINS the failure in plain language — build compilation errors,
    dependency resolution failures, image push authentication issues, health
    check timeouts, resource limit problems, or ingress misconfigurations.
  - RECOMMENDS a fix: whether to retry the pipeline, fix the service
    configuration, update the Dockerfile or buildpack settings, fix
    deployment manifests, or resolve an external issue (registry auth,
    DNS propagation, certificate provisioning).
  - GUIDES the user through resolution — editing service config, fixing
    build files, adjusting deployment targets, or retriggering the pipeline.

The agent reads and analyzes — it does NOT auto-fix or auto-retrigger. Every
mutating action requires explicit user confirmation.

== HOW TO BUILD THIS SKILL — EXPLORE THE PLANTON WORKSPACE ==

The Planton monorepo contains comprehensive documentation about the Service
Hub and its pipeline system. Explore it to build your knowledge:

  - Search for "what-is-*" documentation articles in the Service Hub domain.
    These explain what the Service Hub is (Planton's CI/CD platform, described
    as "Vercel for backend"), what a Service is (the configuration bridge
    between a Git repo and deployment), what a Service Pipeline is (the
    three-stage execution model), and how Kustomize is used for environment-
    specific deployment manifests.

  - Search for self-managed pipeline documentation. Planton supports two
    pipeline modes: platform-managed (automatic) and self-managed (custom
    Tekton pipelines via .planton/pipeline.yaml). The self-managed docs
    include both user guides and developer guides that explain how custom
    Tekton pipelines and tasks are configured.

  - Search for Service Hub-related changelogs under _changelog/ directories.
    These include entries about pipeline fixes, build failure analysis,
    variable resolution issues, and MCP tool additions for Service Hub.

  - Find the protobuf API definitions for Service Hub resources. Key messages
    include:
      * Pipeline, PipelineSpec, PipelineBuildStage, PipelineDeploymentStage
      * ServicePipelineConfiguration (pipeline provider, build method, image
        repo, deploy flags)
      * ServiceEnvironmentDeploymentTarget (per-env deploy config)
      * TektonPipeline, TektonTask (custom pipeline definitions)
    These give you the exact data model for understanding pipeline state
    and diagnosing failures.

  - Search for git webhook documentation. Service Pipelines are triggered by
    git pushes via webhooks — understanding the webhook flow helps diagnose
    "pipeline didn't trigger" issues.

== THREE-STAGE PIPELINE MODEL — CRITICAL ==

Service Pipelines execute through three stages. The skill MUST teach the
agent this model so it can pinpoint WHERE a failure occurred:

  Creation → Build → Deploy

Each stage is a Temporal workflow with its own status and tasks:

  - CREATION stage: sets up the pipeline context, resolves service config,
    prepares build and deploy inputs. Failures here indicate config issues.
  - BUILD stage: builds the container image (Dockerfile or Buildpacks) or
    Cloudflare Worker script, pushes to the container registry. Has tasks,
    DAG structure, and an image_build_failure_analysis field for AI-assisted
    diagnosis. Failures here are compilation errors, dependency issues, or
    registry auth problems.
  - DEPLOY stage: applies Kustomize overlays and deploys to the target
    environment. Has tasks and status tracking. Failures here are deployment
    manifest issues, health check failures, resource limits, or ingress
    misconfigurations.

== BUILD METHOD VARIATIONS ==

The skill should teach the agent to recognize different build modes:

  - DOCKERFILE: standard Docker build — look for Dockerfile syntax errors,
    missing base images, COPY failures, multi-stage build issues.
  - BUILDPACKS: Cloud Native Buildpacks — look for detection failures,
    unsupported language versions, buildpack configuration issues.
  - SELF-MANAGED TEKTON: custom .planton/pipeline.yaml — look for Tekton
    task/pipeline YAML issues, custom step failures, volume mount problems.

Each mode has different failure patterns and different fix approaches.

== COMMON FAILURE PATTERNS ==

The skill should teach the agent to recognize and diagnose:

  Build failures:
  - Dependency resolution (npm install, pip install, go mod download failures)
  - Compilation errors (type errors, syntax errors, missing imports)
  - Image push authentication (expired tokens, wrong registry, permission denied)
  - Base image pull failures (deleted tags, rate limiting, private registry)
  - Resource exhaustion during build (OOM, disk space)

  Deploy failures:
  - Health check timeout (readiness/liveness probes failing)
  - Resource limits (CPU/memory requests too high for the cluster)
  - Image pull errors (wrong tag, private registry auth, image doesn't exist)
  - Ingress/DNS issues (certificate provisioning, DNS propagation, routing)
  - Kustomize overlay errors (invalid patches, missing base resources)
  - Container crash loops (application startup errors, missing env vars)

  Trigger failures:
  - Webhook not received (misconfigured webhook URL, wrong events selected)
  - Branch filter mismatch (push to wrong branch, tag vs branch confusion)
  - Git connection issues (expired SCM connection token)

== KUSTOMIZE CONTEXT ==

Planton uses Kustomize for environment-specific deployment manifests. The
skill should teach the agent to understand:

  - Deployment config can come from Git (kustomize-build from _kustomize/) or
    inline (deployment_targets in service spec).
  - Environment overlays customize base manifests per environment.
  - Common Kustomize errors: invalid patch targets, missing resources,
    strategic merge patch conflicts.

== KEY PRINCIPLES THE SKILL MUST CONVEY ==

  - Always identify which stage (Creation, Build, Deploy) failed first
  - Read the full pipeline status and stage details before diagnosing
  - For build failures, check the image_build_failure_analysis field if
    available — it may already contain useful diagnostic information
  - Distinguish between service config issues and external issues (registry,
    cluster, DNS)
  - When recommending fixes, be specific about which file or config to change
  - Understand the difference between platform-managed and self-managed
    pipelines — troubleshooting differs significantly
  - When a pipeline didn't trigger at all, check webhook and git connection
    configuration
  - When multiple tasks fail, identify the root cause task (often the first
    failure cascades)
  - Never auto-retrigger a failed pipeline — explain the diagnosis and let
    the user decide
  - When deploy failures involve health checks, help the user understand
    what the application needs to be "ready" vs what the probe is checking
PROMPT

stigmer draft skill \
    --workspace "$PLANTON_REPO" \
    --workspace "$REPO_ROOT" \
    -m "$(cat "${_MSG_FILE}")"

echo ""
echo "Done. Generated:"
echo "  skills/service-pipeline-debugger/SKILL.md"
echo "  skills/service-pipeline-debugger/references/*"
echo ""
echo "Next steps:"
echo "  1. Review the generated skill"
echo "  2. Run: ./tools/12_draft-service-pipeline-debugger-agent.sh"
