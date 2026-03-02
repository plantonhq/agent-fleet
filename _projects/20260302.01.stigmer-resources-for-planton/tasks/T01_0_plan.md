# Task T01: Stigmer Resources for Planton — Master Plan

**Created**: 2026-03-02
**Status**: PENDING REVIEW
**Type**: Feature Development

> This plan requires your review before execution. Each phase is self-contained — we plan, execute, and validate one phase before moving to the next.

## Objective

Build a complete Stigmer project in `plantonhq/agent-fleet` that defines an MCP server, 5 AI agents with deep domain skills, and shell-script tooling for the Planton platform.

## Architectural Decisions

### Repository Location
**Decision**: New public repository `plantonhq/agent-fleet`.
- Public visibility for showcasing Stigmer's value
- Aligns with Planton's existing "Agent Fleet" product concept
- Professional URL: `github.com/plantonhq/agent-fleet`

### MCP Server Approach
**Decision**: Use the Stigmer MCP Server Creator agent (not handwritten).
- Demonstrates Stigmer's self-extensibility
- Feed rich context from Planton API docs and existing `mcp-server-planton` implementation

### Cross-Repo Documentation Strategy
- **Local sibling**: Tool scripts check `../planton/docs/product/` for context when drafting skills
- **Bundled references**: Each `skills/*/references/` contains curated excerpts for self-contained portability

---

## Phase 0: Repository Scaffold (DONE)

- [x] Create public repo `plantonhq/agent-fleet` on GitHub
- [x] Clone locally to `~/scm/github.com/plantonhq/agent-fleet/`
- [x] Create `stigmer.yaml` project manifest
- [x] Create directory structure (mcp-servers/, agents/, skills/, tools/)
- [x] Create repo-level README.md
- [x] Create `_projects/` framework for task tracking

---

## Phase 1: Planton MCP Server Definition

**Goal**: Define the MCP server YAML that tells Stigmer how to connect to Planton's API and what tools it exposes.

### Tasks
- [ ] Analyze existing `plantonhq/mcp-server-planton` repo for server implementation details
- [ ] Identify all tools the MCP server should expose:
  - `get-cloud-resources` — List/get Cloud Resources by kind, org, environment
  - `get-stack-jobs` — List/get Stack Jobs with status and logs
  - `apply-manifest` — Apply a Cloud Resource YAML manifest via Planton CLI
  - `get-cloud-resource-kinds` — List all supported Cloud Resource kinds
  - `get-cloud-object-presets` — Retrieve presets for a given resource kind
  - `get-infra-charts` — List available Infra Charts
  - `get-infra-projects` — List Infra Projects with pipeline status
  - `get-infra-pipelines` — Get pipeline execution details
- [ ] Use Stigmer MCP Server Creator agent OR hand-write `mcp-servers/planton-mcp-server.yaml`
- [ ] Validate the YAML against Stigmer's MCP server schema
- [ ] Create `tools/00_create-planton-mcp-server.sh`

### Output
- `mcp-servers/planton-mcp-server.yaml`
- `tools/00_create-planton-mcp-server.sh`

### Context Sources
- `/Users/suresh/scm/github.com/plantonhq/mcp-server-planton/` (server implementation)
- `/Users/suresh/scm/github.com/plantonhq/planton/docs/product/what-is-a-planton-api-resource.md`
- `/Users/suresh/scm/github.com/plantonhq/planton/docs/product/infra-hub/what-is-a-cloud-resource.md`

---

## Phase 2: Cloud Resource Assistant (Agent + Skill)

**Goal**: An agent that helps users create, configure, and deploy any of Planton's 150+ Cloud Resource kinds from natural language.

### Why Highest Value
Directly demonstrates Planton's core value prop ("no DevOps team needed") amplified by AI. A user says "deploy a production PostgreSQL on Kubernetes with 3 replicas and 100Gi storage" and gets a validated, deployable manifest.

### Tasks
- [ ] Curate reference docs into `skills/cloud-resource-assistant/references/`:
  - `what-is-a-cloud-resource.md`
  - `what-is-cloud-resource-kind.md`
  - `what-are-cloud-object-presets-in-planton.md`
  - `what-is-openmcf.md`
  - Protobuf schema snippets (CloudResourceKind enum, example specs)
- [ ] Draft skill using `stigmer draft skill` with attached context
- [ ] Review and refine `skills/cloud-resource-assistant/SKILL.md`
- [ ] Create `agents/cloud-resource-assistant.yaml` linking skill + MCP server
- [ ] Create `tools/01_draft-cloud-resource-assistant.sh`

### Key Knowledge the Skill Must Encode
- Cloud Resource KRM structure (apiVersion, kind, metadata, spec, status)
- Cloud Object Presets as starting points (505 presets across 251 components)
- OpenMCF YAML manifest format
- Protobuf validation rules
- `planton apply` workflow
- ID patterns: `<kind-prefix>-<org>-<name>` (max 27 chars)

### Output
- `skills/cloud-resource-assistant/SKILL.md`
- `skills/cloud-resource-assistant/references/*`
- `agents/cloud-resource-assistant.yaml`
- `tools/01_draft-cloud-resource-assistant.sh`

---

## Phase 3: Stack Job Troubleshooter (Agent + Skill)

**Goal**: An agent that analyzes failed Stack Jobs (Terraform/Pulumi execution errors), understands the Cloud Resource configuration that caused the failure, and suggests fixes.

### Why High Value
Addresses the #1 support burden. Aligns with Planton's existing Agent Fleet strategy (ECS Troubleshooter, Tekton Pipeline Manager). Reduces dependency on DevOps expertise.

### Tasks
- [ ] Curate reference docs into `skills/stack-job-troubleshooter/references/`:
  - `what-is-a-stack-job.md`
  - `what-is-a-cloud-resource.md`
  - IaC error pattern catalog (common Terraform/Pulumi failures)
  - Provider-specific error codes (AWS, GCP, Azure)
- [ ] Draft skill using `stigmer draft skill` with attached context
- [ ] Review and refine `skills/stack-job-troubleshooter/SKILL.md`
- [ ] Create `agents/stack-job-troubleshooter.yaml`
- [ ] Create `tools/02_draft-stack-job-troubleshooter.sh`

### Key Knowledge the Skill Must Encode
- Stack Job lifecycle (init → refresh → preview/plan → apply/destroy)
- Multi-step execution model with step-level logs
- Common Terraform errors (state lock, provider auth, resource limits, quota)
- Common Pulumi errors (dependency conflicts, runtime errors, provider issues)
- How to read Stack Job logs and correlate with Cloud Resource spec
- Retry vs. fix-and-reapply decision framework

### Output
- `skills/stack-job-troubleshooter/SKILL.md`
- `skills/stack-job-troubleshooter/references/*`
- `agents/stack-job-troubleshooter.yaml`
- `tools/02_draft-stack-job-troubleshooter.sh`

---

## Phase 4: Infra Chart Composer (Agent + Skill)

**Goal**: An agent that creates multi-resource Infra Charts from requirements, understanding ValueFromRef dependencies and generating proper DAG structure.

### Why High Value
Power-user multiplier. Reduces "complete environment" setup from hours of manual chart authoring to a conversation. Demonstrates Planton's orchestration layer.

### Tasks
- [ ] Curate reference docs into `skills/infra-chart-composer/references/`:
  - `what-is-an-infra-chart.md`
  - `what-is-an-infra-project.md`
  - `what-is-an-infra-pipeline.md`
  - Existing chart examples (AWS ECS Environment chart from plantonhq/infra-charts)
  - ValueFromRef documentation
- [ ] Draft skill using `stigmer draft skill` with attached context
- [ ] Review and refine `skills/infra-chart-composer/SKILL.md`
- [ ] Create `agents/infra-chart-composer.yaml`
- [ ] Create `tools/03_draft-infra-chart-composer.sh`

### Key Knowledge the Skill Must Encode
- Infra Chart structure (Chart.yaml, values.yaml, templates/)
- Jinjava templating syntax for parameterization
- ValueFromRef dependency mechanism (output of resource A → input of resource B)
- DAG construction for parallel and sequential execution
- Infra Project as rendered chart instance
- Infra Pipeline orchestration of Stack Jobs

### Output
- `skills/infra-chart-composer/SKILL.md`
- `skills/infra-chart-composer/references/*`
- `agents/infra-chart-composer.yaml`
- `tools/03_draft-infra-chart-composer.sh`

---

## Phase 5: Planton Onboarding Guide (Agent + Skill)

**Goal**: An interactive tutorial agent that answers questions about Planton concepts and guides new users through their first deployment.

### Why High Value
Reduces time-to-first-deployment — the critical adoption metric. Every new customer benefits. Uses the rich documentation corpus as knowledge base.

### Tasks
- [ ] Curate reference docs into `skills/planton-onboarding-guide/references/`:
  - `what-is-planton.md` (full product overview)
  - ALL `what-is-*` docs from `docs/product/infra-hub/`
  - Platform hierarchy documentation (Org → Env → CloudResource)
  - CLI quick-start and command reference
  - Web console workflow overview
- [ ] Draft skill using `stigmer draft skill` with attached context
- [ ] Review and refine `skills/planton-onboarding-guide/SKILL.md`
- [ ] Create `agents/planton-onboarding-guide.yaml`
- [ ] Create `tools/04_draft-planton-onboarding-guide.sh`

### Key Knowledge the Skill Must Encode
- Complete Planton product overview (Infra Hub + Service Hub)
- Platform hierarchy and resource relationships
- Credential and connection setup per cloud provider
- Step-by-step first deployment walkthrough
- OpenMCF relationship (open-source foundation)
- Common terminology (Cloud Resource, Cloud Object, Stack Job, Infra Chart, etc.)

### Output
- `skills/planton-onboarding-guide/SKILL.md`
- `skills/planton-onboarding-guide/references/*`
- `agents/planton-onboarding-guide.yaml`
- `tools/04_draft-planton-onboarding-guide.sh`

---

## Phase 6: Service Pipeline Debugger (Agent + Skill)

**Goal**: An agent that troubleshoots failed Tekton CI/CD pipelines — build failures, deployment failures, container image issues, ingress configuration problems.

### Why High Value
Completes "full DevOps lifecycle" coverage alongside Stack Job Troubleshooter. Addresses the Service Hub side of Planton. Already partially validated with Planton's existing Tekton Pipeline Manager agent concept.

### Tasks
- [ ] Curate reference docs into `skills/service-pipeline-debugger/references/`:
  - Service Hub documentation
  - Tekton pipeline structure and task definitions
  - BuildPacks and Dockerfile build documentation
  - Container registry and image patterns
  - Ingress/DNS configuration reference
- [ ] Draft skill using `stigmer draft skill` with attached context
- [ ] Review and refine `skills/service-pipeline-debugger/SKILL.md`
- [ ] Create `agents/service-pipeline-debugger.yaml`
- [ ] Create `tools/05_draft-service-pipeline-debugger.sh`

### Key Knowledge the Skill Must Encode
- Tekton pipeline structure (Pipeline → PipelineRun → TaskRun)
- BuildPacks vs Dockerfile build modes
- Common build failures (dependency resolution, compilation errors, image push auth)
- Common deployment failures (health check timeout, resource limits, image pull)
- Ingress/DNS troubleshooting (certificate issues, DNS propagation, routing rules)
- Git webhook flow and trigger debugging

### Output
- `skills/service-pipeline-debugger/SKILL.md`
- `skills/service-pipeline-debugger/references/*`
- `agents/service-pipeline-debugger.yaml`
- `tools/05_draft-service-pipeline-debugger.sh`

---

## Phase 7: Tooling and Automation

**Goal**: Create the master regeneration script and finalize all documentation.

### Tasks
- [ ] Create `tools/regenerate_all.sh` master script that:
  - Runs all numbered scripts in sequence (00 through 05)
  - Handles doc references gracefully (check sibling `../planton/` or use bundled references)
  - Reports success/failure per script
- [ ] Validate all individual tool scripts can run end-to-end
- [ ] Finalize repo-level `README.md` with:
  - Setup instructions and prerequisites
  - Demo walkthrough
  - Agent usage examples
- [ ] Create a design decision documenting the cross-repo doc strategy

### Output
- `tools/regenerate_all.sh`
- Updated `README.md`
- All tool scripts validated

---

## Demo Narrative

When demonstrating to the Planton founder:

> "We created `agent-fleet` — a public showcase of Stigmer-powered agents for the Planton platform. It defines an MCP server that connects to Planton's API, and 5 specialized agents: a Cloud Resource Assistant that turns natural language into validated infrastructure manifests, a Stack Job Troubleshooter that auto-diagnoses failed deployments, an Infra Chart Composer that assembles multi-resource environments from conversation, an Onboarding Guide that walks new users through their first deployment, and a Service Pipeline Debugger for Tekton CI/CD failures. This is what Stigmer brings: domain-expert AI agents that make Planton's platform accessible without DevOps expertise — and it's all open source."

---

## Review Process

**What happens next**:
1. **You review this plan** — consider the phases, agent selection, and approach
2. **Provide feedback** — any concerns, reordering, additions, or removals
3. **I'll revise** — create `T01_2_revised_plan.md` incorporating feedback
4. **You approve** — give explicit go-ahead
5. **We execute phase by phase** — one session per phase, each tracked in its own task file
