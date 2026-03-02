# Agent Fleet

**Stigmer-powered AI agents for the [Planton](https://planton.cloud) platform.**

Agent Fleet is a [Stigmer](https://stigmer.ai) project that defines specialized AI agents, skills, and an MCP server for Planton — a DevOps-in-a-box platform that lets teams deploy and manage cloud infrastructure without dedicated DevOps expertise.

## Agents

| Agent | Purpose |
|-------|---------|
| **Cloud Resource Assistant** | Create, configure, and deploy any of Planton's 150+ Cloud Resource kinds from natural language |
| **Stack Job Troubleshooter** | Diagnose failed Terraform/Pulumi execution errors and suggest fixes |
| **Infra Chart Composer** | Compose multi-resource Infra Charts with dependency-aware DAG structure |
| **Planton Onboarding Guide** | Walk new users through organization setup, credentials, and first deployment |
| **Service Pipeline Debugger** | Troubleshoot Tekton CI/CD pipeline failures — builds, deployments, ingress |

## Project Structure

```
stigmer.yaml                           # Stigmer project manifest
mcp-servers/
  planton-mcp-server.yaml             # MCP server definition
agents/
  cloud-resource-assistant.yaml
  stack-job-troubleshooter.yaml
  infra-chart-composer.yaml
  planton-onboarding-guide.yaml
  service-pipeline-debugger.yaml
skills/
  cloud-resource-assistant/SKILL.md
  stack-job-troubleshooter/SKILL.md
  infra-chart-composer/SKILL.md
  planton-onboarding-guide/SKILL.md
  service-pipeline-debugger/SKILL.md
tools/
  regenerate_all.sh                    # Regenerate all skills and agents
  00_create-planton-mcp-server.sh
  01_draft-cloud-resource-assistant.sh
  02_draft-stack-job-troubleshooter.sh
  03_draft-infra-chart-composer.sh
  04_draft-planton-onboarding-guide.sh
  05_draft-service-pipeline-debugger.sh
```

## Prerequisites

- [Stigmer CLI](https://stigmer.ai) installed
- [Planton CLI](https://planton.cloud) installed (for MCP server connectivity)
- Access to Planton documentation (sibling `../planton/` clone or bundled references)

## Getting Started

1. Clone this repo alongside the Planton monorepo:
   ```
   cd ~/scm/github.com/plantonhq/
   git clone https://github.com/plantonhq/agent-fleet.git
   ```

2. Register the project with Stigmer:
   ```
   stigmer project register .
   ```

3. Regenerate all skills and agents:
   ```
   cd tools/
   ./regenerate_all.sh
   ```

## Development

This project tracks its work using the Next Project Framework under `_projects/`. To resume work on the current task, drag `_projects/<current-project>/next-task.md` into your AI conversation.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
