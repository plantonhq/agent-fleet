# InfraChart Structure Reference

## Table of Contents

- [Chart.yaml Structure](#chartyaml-structure)
- [values.yaml Structure](#valuesyaml-structure)
- [Parameter Design](#parameter-design)
- [Template Patterns](#template-patterns)
- [Standard Metadata Block](#standard-metadata-block)
- [ValueFromRef Dependencies](#valuefromref-dependencies)
- [Conditional Logic](#conditional-logic)
- [DAG Construction Rules](#dag-construction-rules)
- [Protobuf Field Reference](#protobuf-field-reference)

---

## Chart.yaml Structure

```yaml
apiVersion: infra-hub.planton.ai/v1
kind: InfraChart
metadata:
  name: Human Readable Chart Name
spec:
  selector:
    kind: organization          # or "platform"
    id: <organization-id>
  description: >
    Brief description of what infrastructure this chart deploys.
    Indexed for search — be specific about resource types and purpose.
  iconUrl: https://assets.planton.ai/path/to/icon.svg
  isReady: true                 # false = draft, hidden from catalog
  webLinks:
    chartWebUrl: https://github.com/org/repo/tree/main/path/to/chart
    readmeRawUrl: https://raw.githubusercontent.com/org/repo/refs/heads/main/path/to/chart/README.md
```

### Required Fields

| Field | Description |
|-------|-------------|
| `apiVersion` | Always `infra-hub.planton.ai/v1` |
| `kind` | Always `InfraChart` |
| `metadata.name` | Human-readable display name |
| `spec.selector` | Owner scope — `kind` (organization/platform) + `id` |
| `spec.description` | Search-indexed description |

### Optional Fields

| Field | Description |
|-------|-------------|
| `spec.iconUrl` | SVG icon URL for the catalog |
| `spec.isReady` | `true` to publish, `false` for drafts |
| `spec.webLinks.chartWebUrl` | Link to chart source in git |
| `spec.webLinks.readmeRawUrl` | Raw URL of README.md for inline display |

---

## values.yaml Structure

```yaml
params:
  - name: param_name
    description: What this parameter controls
    type: string              # optional, default is string
    value: default_value      # optional default
    hidden: true              # optional, hides from UI
    enum_values:              # required when type=string_enum
      - option_a
      - option_b
    file_content: true        # optional, renders file upload
    base64_encode: true       # optional, base64 encode file content
```

### Parameter Types

| Type | Proto Enum | Renders As | Notes |
|------|-----------|------------|-------|
| `string` | 0 (default) | Text input | Omit `type` field for string |
| `number` | 1 | Numeric input | For integers and floats |
| `bool` | 2 | Toggle | Values: `true`/`false` |
| `list` | 3 | Multi-value input | Array of strings |
| `string_enum` | 4 | Dropdown | Requires `enum_values` |

### Special Param Flags

| Flag | Effect |
|------|--------|
| `hidden: true` | Hidden from console UI; used for internal wiring (e.g., pulumi_organization) |
| `file_content: true` | Renders file upload widget instead of text input |
| `base64_encode: true` | Base64-encodes uploaded file content (for binary files) |

---

## Parameter Design

### What to parameterize

- **Always parameterize:** `env` (environment name), resource sizing (CPU, memory, disk,
  replicas), feature toggles, external IDs (project IDs, account IDs), credentials.
- **Always hide:** `pulumi_organization`, `pulumi_project` — internal wiring.
- **Never parameterize:** Hardcode sensible defaults for non-cost, non-environment settings
  (API versions, chart versions, boolean flags that rarely change).

### Naming conventions

- Use `snake_case` for parameter names.
- Prefix resource-specific params: `postgres_planton_cpu_limit`, `redis_cache_replicas`.
- Use `env` (not `environment`) for the environment parameter.

### Standard hidden params (include in every chart)

```yaml
  - name: pulumi_organization
    description: Pulumi organization name
    value: organization
    hidden: true

  - name: pulumi_project
    description: Pulumi project name
    value: planton
    hidden: true
```

---

## Template Patterns

### File organization

Organize templates by concern — one file per logical group:

```
templates/
├── namespace.yaml          # Namespace resources
├── network.yaml            # VPC, subnets, NAT
├── compute.yaml            # Clusters, node pools
├── database/
│   ├── postgres.yaml       # PostgreSQL instances
│   └── redis.yaml          # Redis instances
├── dns.yaml                # DNS zones, records
└── monitoring.yaml         # Observability resources
```

### Multiple resources per file

Separate resources with `---`:

```yaml
---
apiVersion: gcp.openmcf.org/v1
kind: GcpVpc
metadata:
  name: "{{ values.env }}-vpc"
  ...
spec:
  ...
---
apiVersion: gcp.openmcf.org/v1
kind: GcpSubnetwork
metadata:
  name: "{{ values.env }}-main-subnet"
  ...
spec:
  ...
```

### Jinjava templating syntax

- **Variable substitution:** `{{ values.param_name }}`
- **Conditionals:** `{% if values.flag == true %}...{% endif %}`
- **Loops:** `{% for item in values.list_param %}...{% endfor %}`
- **All values are accessed via `values.*`** — the `values` object maps directly
  to the resolved `params` in values.yaml.

---

## Standard Metadata Block

Every Cloud Resource in a template MUST have this metadata structure:

```yaml
apiVersion: <provider>.openmcf.org/v1
kind: <CloudResourceKind>
metadata:
  name: "<unique-resource-name>"
  labels:
    openmcf.org/provisioner: pulumi
    pulumi.openmcf.org/organization: {{ values.pulumi_organization }}
    pulumi.openmcf.org/project: {{ values.pulumi_project }}
    pulumi.openmcf.org/stack.name: {{ values.env }}.<Kind>.<resource-name>
  group: <visual-group-name>          # optional, for DAG grouping
  relationships:                       # optional, for topology display
    - kind: <ParentResourceKind>
      name: "<parent-resource-name>"
      type: runs_on
spec:
  ...
```

### apiVersion by provider

| Provider | apiVersion |
|----------|-----------|
| GCP | `gcp.openmcf.org/v1` |
| AWS | `aws.openmcf.org/v1` |
| Azure | `azure.openmcf.org/v1` |
| Kubernetes | `kubernetes.openmcf.org/v1` |
| Cloudflare | `cloudflare.openmcf.org/v1` |
| Confluent | `confluent.openmcf.org/v1` |
| Snowflake | `snowflake.openmcf.org/v1` |
| MongoDB Atlas | `atlas.openmcf.org/v1` |

### stack.name format

`{{ values.env }}.<Kind>.<resource-name>` — uniquely identifies the Pulumi stack.

### group label

Groups related resources visually in the DAG. Examples: `network`, `kubernetes`,
`postgres`, `cache`, `streaming`, `search`, `dns`, `monitoring`.

### relationships

Declare topology for DAG visualization. `type: runs_on` means "this resource
runs on/inside the referenced resource."

---

## ValueFromRef Dependencies

`valueFrom` creates explicit cross-resource dependencies. The DAG builder
extracts these to determine topological execution order.

### Syntax

```yaml
spec:
  someField:
    valueFrom:
      kind: <ProducerResourceKind>
      name: "<producer-resource-name>"
      fieldPath: <dot-separated-path>
```

### Common fieldPath values

| Pattern | Example | Meaning |
|---------|---------|---------|
| `status.outputs.<key>` | `status.outputs.project_id` | Runtime output from the producer |
| `spec.<field>` | `spec.name` | Static spec field from the producer |
| `metadata.name` | `metadata.name` | Resource name |

### Direct value (no dependency)

```yaml
spec:
  someField:
    value: "hardcoded-value"
```

### Conditional valueFrom

Toggle between managed (valueFrom) and pre-existing (direct value):

```yaml
spec:
  projectId:
{% if values.managed_by_planton %}
    valueFrom:
      kind: GcpProject
      name: "{{ values.project_slug }}"
      fieldPath: status.outputs.project_id
{% else %}
    value: "{{ values.project_id }}"
{% endif %}
```

### Cross-chart valueFrom (reference nodes)

When Chart B references a resource from Chart A, the DAG includes it as a
**reference node** that is discovered (validated to exist) rather than deployed.
This is the standard pattern for namespace references:

```yaml
spec:
  namespace:
    valueFrom:
      kind: KubernetesNamespace
      name: planton-{{ values.env }}-namespace
      fieldPath: spec.name
```

---

## Conditional Logic

### Conditional resource creation

Wrap entire resources in conditionals to optionally include them:

```yaml
{% if values.create_dns_zone == true %}
---
apiVersion: cloudflare.openmcf.org/v1
kind: CloudflareDnsZone
metadata:
  name: my-zone
  ...
spec:
  ...
{% endif %}
```

### Conditional field values

```yaml
spec:
  replicas: {% if values.env == 'prod' %}3{% else %}1{% endif %}
```

---

## DAG Construction Rules

The platform automatically builds a DAG from template resources:

1. **Nodes** — each Cloud Resource manifest becomes a DAG node.
2. **Edges** — each `valueFrom` reference creates a directed edge
   (producer → consumer).
3. **Topological order** — the platform sorts nodes so producers
   deploy before consumers.
4. **Cycle detection** — circular `valueFrom` chains are rejected.
5. **Reference nodes** — cross-chart `valueFrom` references become
   `reference` role nodes that are discovered, not deployed.
6. **Group nodes** — resources with the same `group` label are
   visually grouped in the DAG.

### Avoiding DAG issues

- Every `valueFrom.name` must match an existing resource `metadata.name`
  in the same chart (or be a valid cross-chart reference).
- Every `valueFrom.kind` must match the `kind` of the referenced resource.
- No circular dependency chains.
- Use unique `metadata.name` values within a chart.

---

## Protobuf Field Reference

### InfraChartSpec (spec.proto)

| Field | Type | Description |
|-------|------|-------------|
| `selector` | `ApiResourceSelector` | Owner scope (kind + id) |
| `description` | `string` | Brief description (search-indexed) |
| `is_ready` | `bool` | Ready state flag |
| `icon_url` | `string` | Chart icon URL |
| `template_yaml_files` | `map<string, string>` | Template files (filename → content) |
| `values_yaml` | `string` | Raw values.yaml content |
| `params` | `repeated InfraChartParam` | Parsed parameter list |
| `web_links` | `InfraChartWebLinks` | README + chart web URLs |

### InfraChartParam (param.proto)

| Field | Type | Description |
|-------|------|-------------|
| `name` | `string` | Parameter key (required, unique) |
| `description` | `string` | Help text |
| `type` | `ParamType` | string(0), number(1), bool(2), list(3), string_enum(4) |
| `value` | `Value` | Default/current value |
| `enum_values` | `repeated string` | Allowed values when type=string_enum |
| `hidden` | `bool` | Hide from console UI |
| `file_content` | `bool` | Render file upload |
| `base64_encode` | `bool` | Base64 encode uploaded content |

### CloudResourceDagNode

| Field | Type | Description |
|-------|------|-------------|
| `id` | `CloudResourceDagResource` | Vertex identity (kind + env + slug) |
| `edges` | `repeated CloudResourceDagDependencyEdge` | Outgoing edges |
| `role` | `CloudResourceDagNodeRole` | resource(1), group(2), reference(3) |
| `group_label` | `string` | UI label for group nodes |
| `resource_group` | `string` | Group path (e.g., "app/services") |
| `container_id` | `string` | Enclosing container resource ID |
| `container_kind` | `bool` | Whether this node IS a container |
| `gate` | `CloudResourceDagNodeGate` | Manual gate config |
