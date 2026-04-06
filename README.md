# IaC Security Scanning — POC

This repository is a proof of concept for org-wide IaC security scanning using [Checkov](https://www.checkov.io/). It demonstrates the scanning approach, workflow architecture, and sample IaC across Terraform, Helm, and Docker before rolling out to production repos.

---

## Architecture

Security scanning is split by layer, each with its own reusable workflow living in the central workflows repo. Individual repos call them — they don't own the scanning logic.

```
central-workflows repo
├── terraform-security-scan.yml   ← reusable, called by Terraform repos
└── helm-security-scan.yml        ← embedded into the existing Helm test workflow
```

### Terraform repos
Each Terraform repo calls `terraform-security-scan.yml` on every PR touching `.tf` files. Checkov scans the full directory, posts a structured findings table as a PR comment, and blocks merge on failures.

### Helm repos
Security scanning is added as steps inside the existing `helm-test` workflow — no separate workflow. Checkov runs per changed chart (same matrix the test workflow already produces) immediately after `helm template`.

### Scanning config
`.checkov.yaml` lives in the central workflows repo and is fetched by the workflow at runtime — one place to manage skip-checks and policy across all repos.

---

## What Checkov scans

| Framework | What it checks |
|-----------|---------------|
| `terraform` | GCP resources — GKE, GCS, VPC, Compute misconfigurations |
| `helm` | Kubernetes security contexts, RBAC, resource limits, pod security |
| `dockerfile` | Base image pinning, non-root user, healthcheck |

---

## PR comment

On every PR, a comment is posted with a per-framework summary and a detailed table of failures showing check ID, what it checks, the resource, file, and line number. The job fails and blocks merge if any violations are found.

---

## Repo structure

```
.github/workflows/
  iac-security.yml              # example caller workflow (for this POC repo)
  terraform-security-scan.yml   # reusable Terraform scan workflow
  helm-security-scan.yml        # reusable Helm scan workflow

terraform/
  environments/
    dev/                        # intentionally insecure — demonstrates Checkov findings
    prod/                       # hardened — target state
  modules/
    gcs/                        # GCS bucket module
    gke/                        # GKE cluster + node pool module
    vpc/                        # VPC, subnets, firewall rules

helm/
  charts/
    backend-api/                # sample Helm chart with insecure defaults

docker/
  Dockerfile.dev                # insecure — demonstrates Dockerfile findings
  Dockerfile.prod               # hardened reference

.checkov.yaml                   # Checkov config — frameworks, skip-paths, skip-checks
```

---

## Skipped checks

Any permanently skipped check must be documented in `.checkov.yaml` with a reason and a reference (ADR, ticket, or approved exception). This list is treated as a risk register and reviewed quarterly.
