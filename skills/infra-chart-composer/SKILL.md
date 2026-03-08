---
name: infra-chart-composer
description: "Compose, modify, and validate Planton InfraCharts. Use when users want to: create new InfraCharts from natural-language requirements, modify existing InfraCharts (add/remove resources, update params, fix dependencies), build or repair ValueFromRef dependency chains and DAG structures, apply Jinjava templating and conditional logic, or validate cloud resource spec fields against schemas. Produces files (Chart.yaml, values.yaml, templates/*.yaml, README.md) but does NOT deploy."
---

# InfraChart Composer

## Quick Orientation

An InfraChart is "a Helm chart for infrastructure" — parameterized Jinjava templates
that package Cloud Resources into reusable, dependency-aware bundles deployed via
the Planton platform.

**Three files define every chart:**

| File | Purpose |
|------|---------|
| `Chart.yaml` | Metadata, selector, description, icon, web links |
| `values.yaml` | Parameters with types, defaults, descriptions |
| `templates/*.yaml` | Jinjava-templated Cloud Resource manifests |

Read `references/chart-structure.md` for exact field definitions, value types,
and the standard metadata block every resource must carry.

## Core Workflow

### Determine the operation type

- **New chart** → Follow "Compose a New Chart" below
- **Modify existing chart** → Follow "Modify an Existing Chart" below

### Compose a New Chart

1. **Gather requirements** — ask what infrastructure is needed, target cloud
   provider(s), environment naming, and any cross-chart dependencies.
2. **Discover schemas** — for every Cloud Resource kind needed, fetch the
   schema via the MCP server (see "Schema Discovery" below). Never guess
   field names.
3. **Design parameters** — expose only values that vary per environment or
   affect cost. Hide internal wiring params. See `references/chart-structure.md`
   § Parameter Design.
4. **Write templates** — one file per concern (network, compute, database, etc.).
   Use `valueFrom` for cross-resource wiring. See `references/chart-structure.md`
   § Template Patterns and `references/examples.md` for real production patterns.
5. **Build Chart.yaml and values.yaml** — follow the exact structure in
   `references/chart-structure.md`.
6. **Write README.md** — describe what the chart deploys, parameter table,
   dependency graph, deployment order.
7. **Validate** — verify all `valueFrom` references resolve, DAG has no cycles,
   all resource kinds exist in the catalog.

### Modify an Existing Chart

1. **Read all chart files** to understand current structure and conventions.
2. **Preserve existing conventions** — match naming patterns, param style,
   grouping strategy.
3. **When adding resources:**
   - Fetch the schema for the new resource kind.
   - Wire dependencies via `valueFrom` to existing resources.
   - Verify DAG integration — no orphans, no cycles.
   - Add new parameters only if the resource needs user-configurable values.
4. **When removing resources:**
   - Search all templates for `valueFrom` references to the resource being removed.
   - Update or remove dependents that would break.
   - Remove orphaned parameters from `values.yaml`.
5. **When updating parameters:**
   - Preserve backward compatibility — don't rename params without updating templates.
   - Update descriptions to reflect new behavior.

## Schema Discovery

The platform has 300+ Cloud Resource kinds. Discover schemas on-demand:

1. **List available kinds:**
   Read the MCP resource `cloud-resource-kinds://catalog` to get all kinds
   grouped by provider.

2. **Fetch a specific schema:**
   Read the MCP resource `cloud-resource-schema://{kind}` (e.g.,
   `cloud-resource-schema://GcpGkeCluster`) to get the full JSON schema
   with field names, types, and validation rules.

**Rule:** Always fetch the schema before writing a resource template.
Never assume field names from memory — schemas evolve.

## Changelog-Driven Learning

When the Planton monorepo is available in the workspace, search changelogs
for recent InfraChart changes:

```
grep -r "infra.chart\|InfraChart\|infra-chart\|ValueFromRef\|valuefrom" _changelog/ --include="*.md" -l
```

Read relevant changelogs to learn about new patterns, parameter types,
DAG improvements, or structural changes. This future-proofs your knowledge.

## Key Principles

- Always fetch the schema before writing resource templates.
- Always include clear `description` for every parameter.
- Always document dependencies so the DAG is explicit — use `valueFrom`
  and `metadata.relationships`.
- Prefer multi-file templates organized by concern (network, compute, data, etc.).
- Minimize exposed parameters — hardcode sensible defaults for non-cost settings.
- Use `group` labels on metadata for visual DAG organization.
- Write a README.md for every chart.
- The agent produces files — it does NOT deploy.

## Reference Files

| File | When to Read |
|------|-------------|
| `references/chart-structure.md` | Always — field definitions, param types, metadata block, template syntax |
| `references/examples.md` | When writing templates — real production patterns at varying complexity |
