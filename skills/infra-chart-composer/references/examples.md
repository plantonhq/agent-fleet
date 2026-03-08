# InfraChart Production Examples

## Table of Contents

- [Simple: Environment Namespace](#simple-environment-namespace)
- [Simple: GCP Project](#simple-gcp-project)
- [Medium: DNS Stack with Conditionals](#medium-dns-stack-with-conditionals)
- [Complex: GKE Cluster with Deep ValueFrom Chains](#complex-gke-cluster-with-deep-valuefrom-chains)
- [Complex: Data Stack with Cross-Chart References](#complex-data-stack-with-cross-chart-references)
- [Pattern Catalog](#pattern-catalog)

---

## Simple: Environment Namespace

The simplest possible chart — one resource, three parameters.

### Chart.yaml

```yaml
apiVersion: infra-hub.planton.ai/v1
kind: InfraChart
metadata:
  name: Planton Environment Namespace
spec:
  selector:
    kind: organization
    id: planton
  description: Environment namespace creation with proper labels and annotations for Planton Cloud control plane
  iconUrl: https://assets.planton.ai/apis/infrahub/cloudresource/v1/assets/provider/kubernetes/kubernetesnamespace/v1/logo.svg
  isReady: true
  webLinks:
    chartWebUrl: https://github.com/plantonhq/planton/tree/main/ops/organizations/planton/infra-hub/infra-charts/planton-env-namespace
    readmeRawUrl: https://raw.githubusercontent.com/plantonhq/planton/refs/heads/main/ops/organizations/planton/infra-hub/infra-charts/planton-env-namespace/README.md
```

### values.yaml

```yaml
params:
  - name: pulumi_organization
    description: Pulumi organization name
    value: organization
    hidden: true

  - name: pulumi_project
    description: Pulumi project name
    value: planton
    hidden: true

  - name: env
    description: Environment name (e.g., dev, staging, prod). Namespace will be created as 'planton-{env}'
    value: dev
```

### templates/namespace.yaml

```yaml
---
apiVersion: kubernetes.openmcf.org/v1
kind: KubernetesNamespace
metadata:
  name: planton-{{ values.env }}-namespace
  labels:
    openmcf.org/provisioner: pulumi
    pulumi.openmcf.org/organization: {{ values.pulumi_organization }}
    pulumi.openmcf.org/project: {{ values.pulumi_project }}
    pulumi.openmcf.org/stack.name: {{ values.env }}.KubernetesNamespace.planton-{{ values.env }}
spec:
  name: planton-{{ values.env }}
  labels:
    environment: {{ values.env }}
    type: control-plane
    managed-by: planton
  annotations:
    description: "Control plane namespace for {{ values.env }} environment"
    created-by: "planton-env-namespace InfraChart"
```

**Key patterns:** Simple variable substitution, standard metadata block, no valueFrom (root resource).

---

## Simple: GCP Project

Single resource with boolean parameter and no valueFrom — a root resource others depend ON.

### values.yaml

```yaml
params:
  - name: pulumi_organization
    description: Pulumi organization name
    value: organization
    hidden: true

  - name: pulumi_project
    description: Pulumi project name
    value: planton
    hidden: true

  - name: env
    description: Environment name for the GCP project
    value: gcp-shared

  - name: project_id
    description: GCP Project ID base name. A random suffix is appended automatically.

  - name: organization_id
    description: GCP Organization ID (numeric). Find via gcloud organizations list

  - name: billing_account_id
    description: GCP billing account ID (format XXXXXX-XXXXXX-XXXXXX)

  - name: delete_protection
    description: Prevent accidental deletion of the project
    type: bool
    value: true
    hidden: true
```

### templates/gcp-project.yaml

```yaml
---
apiVersion: gcp.openmcf.org/v1
kind: GcpProject
metadata:
  name: "{{ values.project_id }}"
  labels:
    openmcf.org/provisioner: pulumi
    pulumi.openmcf.org/organization: {{ values.pulumi_organization }}
    pulumi.openmcf.org/project: {{ values.pulumi_project }}
    pulumi.openmcf.org/stack.name: {{ values.env }}.GcpProject.{{ values.project_id }}
spec:
  projectId: "{{ values.project_id }}"
  deleteProtection: {{ values.delete_protection }}
  addSuffix: true
  parentType: organization
  parentId: "{{ values.organization_id }}"
  billingAccountId: "{{ values.billing_account_id }}"
  disableDefaultNetwork: true
  enabledApis:
    - compute.googleapis.com
    - container.googleapis.com
    - dns.googleapis.com
    - iam.googleapis.com
```

**Key patterns:** Boolean param with `type: bool`, hardcoded lists (enabledApis), root resource.

---

## Medium: DNS Stack with Conditionals

Seven templates demonstrating conditional resource creation and conditional valueFrom.

### Conditional resource creation (entire resource gated by a flag)

```yaml
{% if values.create_zone_planton_cloud == true %}
---
apiVersion: cloudflare.openmcf.org/v1
kind: CloudflareDnsZone
metadata:
  name: planton-cloud
  labels:
    openmcf.org/provisioner: pulumi
    pulumi.openmcf.org/organization: {{ values.pulumi_organization }}
    pulumi.openmcf.org/project: {{ values.pulumi_project }}
    pulumi.openmcf.org/stack.name: {{ values.env }}.CloudflareDnsZone.planton-cloud
spec:
  zone_name: {{ values.domain_planton_cloud }}
  account_id: {{ values.cloudflare_account_id }}
  plan: FREE
  paused: false
  default_proxied: false
{% endif %}
```

### Conditional valueFrom (toggle managed vs pre-existing)

```yaml
---
apiVersion: kubernetes.openmcf.org/v1
kind: KubernetesExternalDns
metadata:
  name: external-dns-planton-cloud
  labels:
    openmcf.org/provisioner: pulumi
    pulumi.openmcf.org/organization: {{ values.pulumi_organization }}
    pulumi.openmcf.org/project: {{ values.pulumi_project }}
    pulumi.openmcf.org/stack.name: {{ values.env }}.KubernetesExternalDns.external-dns-planton-cloud
spec:
  namespace:
    valueFrom:
      kind: KubernetesNamespace
      name: external-dns-namespace
      fieldPath: spec.name
  create_namespace: false
  cloudflare:
    api_token: {{ values.cloudflare_api_token }}
    dns_zone_id:
{% if values.create_zone_planton_cloud == true %}
      valueFrom:
        kind: CloudflareDnsZone
        name: planton-cloud
        fieldPath: status.outputs.zone_id
{% else %}
      value: "{{ values.zone_id_planton_cloud }}"
{% endif %}
    is_proxied: false
```

**Key patterns:** `{% if %}` wrapping entire resources, conditional `valueFrom` vs `value`,
cross-resource namespace dependency.

---

## Complex: GKE Cluster with Deep ValueFrom Chains

Five templates demonstrating deep dependency chains across resource types.

### Dependency chain

```
GcpProject -> GcpVpc -> GcpSubnetwork -> GcpGkeCluster -> GcpGkeNodePool
                      -> GcpRouterNat ---^
```

### templates/network.yaml (3 resources, chained valueFrom)

```yaml
---
apiVersion: gcp.openmcf.org/v1
kind: GcpVpc
metadata:
  name: "{{ values.env }}-vpc"
  labels:
    openmcf.org/provisioner: pulumi
    pulumi.openmcf.org/organization: {{ values.pulumi_organization }}
    pulumi.openmcf.org/project: {{ values.pulumi_project }}
    pulumi.openmcf.org/stack.name: {{ values.env }}.GcpVpc.{{ values.env }}-vpc
  group: network
{% if values.gcp_project_managed_by_planton %}
  relationships:
    - kind: GcpProject
      name: "{{ values.gcp_project_cloud_resource_slug }}"
      type: runs_on
{% endif %}
spec:
  networkName: "{{ values.env }}-vpc"
  projectId:
{% if values.gcp_project_managed_by_planton %}
    valueFrom:
      kind: GcpProject
      name: "{{ values.gcp_project_cloud_resource_slug }}"
      fieldPath: status.outputs.project_id
{% else %}
    value: "{{ values.gcp_project_id }}"
{% endif %}
  autoCreateSubnetworks: false
  routingMode: REGIONAL
---
apiVersion: gcp.openmcf.org/v1
kind: GcpSubnetwork
metadata:
  name: "{{ values.env }}-vpc-main-subnet"
  labels:
    openmcf.org/provisioner: pulumi
    pulumi.openmcf.org/organization: {{ values.pulumi_organization }}
    pulumi.openmcf.org/project: {{ values.pulumi_project }}
    pulumi.openmcf.org/stack.name: {{ values.env }}.GcpSubnetwork.{{ values.env }}-vpc-main-subnet
  group: network
  relationships:
    - kind: GcpVpc
      name: "{{ values.env }}-vpc"
      type: runs_on
spec:
  projectId:
{% if values.gcp_project_managed_by_planton %}
    valueFrom:
      kind: GcpProject
      name: "{{ values.gcp_project_cloud_resource_slug }}"
      fieldPath: status.outputs.project_id
{% else %}
    value: "{{ values.gcp_project_id }}"
{% endif %}
  vpcSelfLink:
    valueFrom:
      kind: GcpVpc
      name: "{{ values.env }}-vpc"
      fieldPath: status.outputs.network_self_link
  region: "{{ values.region }}"
  ipCidrRange: "10.0.0.0/20"
  secondaryIpRanges:
    - rangeName: "pods"
      ipCidrRange: "10.4.0.0/14"
    - rangeName: "services"
      ipCidrRange: "10.8.0.0/20"
---
apiVersion: gcp.openmcf.org/v1
kind: GcpRouterNat
metadata:
  name: "{{ values.env }}-router-nat"
  labels:
    openmcf.org/provisioner: pulumi
    pulumi.openmcf.org/organization: {{ values.pulumi_organization }}
    pulumi.openmcf.org/project: {{ values.pulumi_project }}
    pulumi.openmcf.org/stack.name: {{ values.env }}.GcpRouterNat.{{ values.env }}-router-nat
  group: network
  relationships:
    - kind: GcpVpc
      name: "{{ values.env }}-vpc"
      type: runs_on
spec:
  projectId:
{% if values.gcp_project_managed_by_planton %}
    valueFrom:
      kind: GcpProject
      name: "{{ values.gcp_project_cloud_resource_slug }}"
      fieldPath: status.outputs.project_id
{% else %}
    value: "{{ values.gcp_project_id }}"
{% endif %}
  vpcSelfLink:
    valueFrom:
      kind: GcpVpc
      name: "{{ values.env }}-vpc"
      fieldPath: status.outputs.network_self_link
  region: "{{ values.region }}"
```

### templates/gke-cluster.yaml (references multiple producers)

```yaml
---
apiVersion: gcp.openmcf.org/v1
kind: GcpGkeCluster
metadata:
  name: "{{ values.env }}-cluster"
  labels:
    openmcf.org/provisioner: pulumi
    pulumi.openmcf.org/organization: {{ values.pulumi_organization }}
    pulumi.openmcf.org/project: {{ values.pulumi_project }}
    pulumi.openmcf.org/stack.name: {{ values.env }}.GcpGkeCluster.{{ values.env }}-cluster
  group: kubernetes
spec:
  clusterName: "{{ values.env }}-cluster"
  projectId:
{% if values.gcp_project_managed_by_planton %}
    valueFrom:
      kind: GcpProject
      name: "{{ values.gcp_project_cloud_resource_slug }}"
      fieldPath: status.outputs.project_id
{% else %}
    value: "{{ values.gcp_project_id }}"
{% endif %}
  networkSelfLink:
    valueFrom:
      kind: GcpVpc
      name: "{{ values.env }}-vpc"
      fieldPath: status.outputs.network_self_link
  subnetworkSelfLink:
    valueFrom:
      kind: GcpSubnetwork
      name: "{{ values.env }}-vpc-main-subnet"
      fieldPath: status.outputs.subnetwork_self_link
  location: "{{ values.region }}"
  clusterSecondaryRangeName:
    value: "pods"
  servicesSecondaryRangeName:
    value: "services"
  masterIpv4CidrBlock: "172.16.0.0/28"
  enablePublicNodes: false
  releaseChannel: "REGULAR"
```

### templates/node-pools/control-plane.yaml (child of cluster)

```yaml
---
apiVersion: gcp.openmcf.org/v1
kind: GcpGkeNodePool
metadata:
  name: control-plane-pool
  labels:
    openmcf.org/provisioner: pulumi
    pulumi.openmcf.org/organization: {{ values.pulumi_organization }}
    pulumi.openmcf.org/project: {{ values.pulumi_project }}
    pulumi.openmcf.org/stack.name: {{ values.env }}.GcpGkeNodePool.control-plane-pool
  group: kubernetes
  relationships:
    - kind: GcpGkeCluster
      name: "{{ values.env }}-cluster"
      type: runs_on
spec:
  nodePoolName: control-plane-pool
  clusterName:
    valueFrom:
      kind: GcpGkeCluster
      name: "{{ values.env }}-cluster"
      fieldPath: metadata.name
  clusterLocation:
    valueFrom:
      kind: GcpGkeCluster
      name: "{{ values.env }}-cluster"
      fieldPath: spec.location
  machineType: "{{ values.control_plane_node_pool_machine_type }}"
  diskSizeGb: 100
  diskType: "pd-standard"
  imageType: "COS_CONTAINERD"
  spot: false
  autoscaling:
    locationPolicy: BALANCED
    minNodes: 1
    maxNodes: 3
```

**Key patterns:** Multi-resource files, deep valueFrom chains, conditional managed/unmanaged,
group labels, relationships metadata, referencing both `status.outputs.*` and `spec.*` fields.

---

## Complex: Data Stack with Cross-Chart References

Ten+ templates deploying databases, caches, and streaming across providers.

### Cross-chart namespace reference

```yaml
---
apiVersion: kubernetes.openmcf.org/v1
kind: KubernetesPostgres
metadata:
  name: postgres-{{ values.env }}-planton
  labels:
    openmcf.org/provisioner: pulumi
    pulumi.openmcf.org/organization: {{ values.pulumi_organization }}
    pulumi.openmcf.org/project: {{ values.pulumi_project }}
    pulumi.openmcf.org/stack.name: {{ values.env }}.KubernetesPostgres.postgres-{{ values.env }}-planton
  group: postgres
spec:
  namespace:
    valueFrom:
      kind: KubernetesNamespace
      name: planton-{{ values.env }}-namespace
      fieldPath: spec.name
  container:
    replicas: {{ values.postgres_planton_replicas }}
    resources:
      limits:
        cpu: "{{ values.postgres_planton_cpu_limit }}"
        memory: "{{ values.postgres_planton_memory_limit }}"
      requests:
        cpu: "{{ values.postgres_planton_cpu_request }}"
        memory: "{{ values.postgres_planton_memory_request }}"
    diskSize: "{{ values.postgres_planton_disk_size }}"
  users:
    - name: planton
      flags: []
  databases:
    - name: db_iam
      owner_role: planton
    - name: db_billing
      owner_role: planton
  ingress:
    enabled: true
    hostname: postgres-{{ values.env }}-planton.planton.live
```

**Key patterns:** Cross-chart `valueFrom` (namespace from another chart becomes a reference node),
heavily parameterized resource sizing, hardcoded database/user definitions.

---

## Pattern Catalog

### 1. Root resource (no valueFrom, others depend on it)
Use for: GCP Projects, Namespaces, VPCs

### 2. Chained dependency (valueFrom to upstream resource in same chart)
Use for: Subnet -> VPC, Cluster -> VPC + Subnet, NodePool -> Cluster

### 3. Cross-chart reference (valueFrom to resource from another chart)
Use for: Database -> Namespace (from env-namespace chart)

### 4. Conditional creation ({% if %} wrapping entire resource)
Use for: Optional DNS zones, feature-gated resources

### 5. Conditional valueFrom (managed vs pre-existing)
Use for: GCP Project managed by Planton vs bring-your-own

### 6. Multi-resource file (--- separators)
Use for: Network stack (VPC + Subnet + NAT), related resources

### 7. Parameterized sizing (CPU, memory, disk, replicas)
Use for: Databases, caches, compute resources

### 8. Group labels (group: network, group: kubernetes)
Use for: Visual organization in DAG display
