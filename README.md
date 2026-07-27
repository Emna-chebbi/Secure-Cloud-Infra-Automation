# Secure Cloud Infrastructure Automation

**Terraform · Ansible · Docker · Microsoft Azure · GitHub Actions · Prometheus/Grafana**

![Terraform](https://img.shields.io/badge/Terraform-IaC-844FBA?logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-Config%20Management-EE0000?logo=ansible&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?logo=microsoftazure&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containers-2496ED?logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)
![Checkov](https://img.shields.io/badge/Checkov-IaC%20Security-6C4EE3)
![Trivy](https://img.shields.io/badge/Trivy-Vuln%20Scanning-1904DA)

A production-style, two-tier cloud infrastructure — web server and database server — provisioned entirely as code, configured entirely as code, scanned for security misconfigurations before every deployment, and shipped through a branch-gated CI/CD pipeline with a manual approval gate before anything touches real cloud resources.

No manual clicking through a cloud console. No manually-installed packages. No hand-edited server configs. Everything — from virtual network creation to database backup scheduling — is reproducible from a clean `git clone`.

> Built as a hands-on demonstration of production-grade Infrastructure as Code, cloud networking, configuration management, DevSecOps practices, and CI/CD pipeline design for infrastructure — not application code.

---

## Table of contents

- [Architecture](#architecture)
- [Why this project exists](#why-this-project-exists)
- [Skills demonstrated](#skills-demonstrated)
- [Tech stack](#tech-stack)
- [Repository structure](#repository-structure)
- [CI/CD pipeline](#cicd-pipeline)
- [Security](#security)
- [Monitoring](#monitoring)
- [Running it yourself](#running-it-yourself)


---

## Architecture

Internet traffic reaches only the web server, on ports 80/443. SSH access is restricted to a single administrator IP, resolved dynamically on every `terraform apply` via a Terraform HTTP data source — no hardcoded, easily-stale IP allowlists.

**The database server has no public IP at all.** It is reached exclusively through the web server acting as an SSH bastion host, and it accepts application traffic on port 5432 only from within the private virtual network — never the internet. This is a deliberate zero-trust design decision, not the default Terraform would give you.

```
                            Internet
                               │  HTTPS :80/443, SSH :22 (admin IP only)
                               ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  Azure Virtual Network (10.0.0.0/16)                                         │
│                                                                              │
│  ┌─────────────────────┐   SSH jump / :5432      ┌─────────────────────┐     │
│  │   Web server        ├────────────────────────►│   DB server         │     │
│  │   (public IP)       │                         │   (private only)    │     │
│  │  Nginx · Docker     │                         │  PostgreSQL         │     │
│  │  Prometheus/Grafana │                         │  Automated backups  │     │
│  └─────────────────────┘                         └─────────────────────┘     │
└──────────────────────────────────────────────────────────────────────────────┘
                                   ▲
                                   │ terraform apply · ansible-playbook
                       ┌───────────────────────┐
                       │  GitHub Actions CI/CD │
                       └───────────────────────┘
```

| Layer | Technology | Responsibility |
|---|---|---|
| Provisioning | Terraform, `azurerm` provider | VNet, subnet, NSGs, VMs, remote state with locking |
| Configuration | Ansible (roles, handlers, templates, Vault) | OS hardening, service install/config, secrets |
| Containerization | Docker, Docker Compose | Application packaging and deployment |
| Security scanning | Checkov, Trivy | IaC misconfiguration, image CVEs, leaked secrets |
| CI/CD | GitHub Actions | Validate → scan → plan → approve → apply → configure |
| Observability | Prometheus, Grafana, Node Exporter | Host-level metrics and dashboards |

---

## Why this project exists

This project deliberately goes one layer deeper: **the infrastructure itself is the product being engineered.** It exists to demonstrate the specific skill set of a DevOps/Cloud engineer.

- Designing and provisioning real cloud networking (VNets, subnets, NSGs)
- Treating configuration management as a first-class, idempotent, testable discipline
- Building a CI/CD pipeline that understands the difference in risk between validating code and mutating real infrastructure
- Applying shift-left security scanning and treating findings as things to triage and justify, not silence
- Designing network access with zero-trust principles by default (no public IP where none is needed)

---

## Skills demonstrated

**Cloud Infrastructure & Networking**
Virtual network design and subnetting · Network Security Groups and least-privilege firewall rules · public vs. private IP architecture · bastion host patterns · Azure Resource Manager

**Infrastructure as Code**
Terraform providers, variables, remote state with locking, data sources, outputs · reproducible, idempotent infrastructure · state management across CI and local environments

**Configuration Management**
Ansible roles, handlers, Jinja2 templates, dynamic inventory, `group_vars` variable precedence · Ansible Vault for encrypted secrets · idempotent OS hardening at scale

**Containerization**
Multi-stage-aware Dockerfiles · Docker Compose service orchestration · container hardening (`no-new-privileges`, restricted port binding) · image vulnerability scanning

**DevSecOps**
Static analysis for IaC (Checkov) · container and filesystem vulnerability scanning (Trivy) · encrypted secrets management · defense-in-depth firewalling at network *and* host layers

**CI/CD Engineering**
Multi-stage GitHub Actions pipelines · environment-gated manual approval for high-risk operations · workflow chaining (`workflow_run`) · concurrency control to protect shared state · ephemeral-runner-safe credential handling

**Observability**
Prometheus scrape configuration · Grafana dashboard provisioning as code · Node Exporter deployment via configuration management

---

## Tech stack

**Cloud:** Microsoft Azure (Virtual Network, Network Security Groups, Linux Virtual Machines, Storage Account for remote state)
**IaC:** Terraform ≥1.15
**Configuration Management:** Ansible ≥2.15
**Containers:** Docker, Docker Compose
**Security:** Checkov, Trivy, Ansible Vault, UFW, fail2ban
**CI/CD:** GitHub Actions
**Observability:** Prometheus, Grafana, Node Exporter
**OS:** Ubuntu 22.04 LTS

---

## Repository structure

```
Secure-Cloud-Infra-Automation/
├── terraform/
│   ├── provider.tf          # Provider + backend configuration
│   ├── backend.tf           # Remote state (Azure Storage, with locking)
│   ├── variables.tf         # Typed, documented input variables
│   ├── network.tf           # VNet, subnet, public IPs, NICs
│   ├── security.tf          # NSGs and security rules
│   ├── compute.tf           # Linux VMs + Terraform-generated SSH keypair
│   ├── data.tf              # Dynamic admin-IP resolution
│   └── outputs.tf           # IPs, admin username, key path
├── ansible/
│   ├── ansible.cfg
│   ├── playbook.yml          # Top-level orchestration (3 scoped plays)
│   ├── requirements.yml      # Pinned Galaxy collections
│   ├── group_vars/
│   │   ├── all.yml
│   │   ├── web.yml / db.yml  # Per-host-group overrides
│   │   └── all/vault.yml     # Ansible Vault (AES-256 encrypted)
│   └── roles/
│       ├── security/         # SSH hardening, UFW, fail2ban
│       ├── docker/           # Docker Engine + Compose plugin
│       ├── nginx/            # Reverse proxy → containerized app
│       ├── postgres/         # DB, user, automated nightly backups
│       ├── app/              # Application container deployment
│       ├── node_exporter/    # Metrics agent (both hosts)
│       └── monitoring/       # Prometheus + Grafana (web host)
├── docker/
│   ├── app/                 # Application Dockerfile + static content
│   └── docker-compose.yml
├── scripts/
│   └── generate-inventory.sh # Terraform outputs → live Ansible inventory
├── .github/workflows/
│   ├── infra-ci.yml          # fmt · validate · plan · Checkov · Trivy · ansible-lint
│   ├── infra-deploy.yml      # apply + Ansible configure (environment-approval gated)
│   └── destroy.yml           # Manual, approval-gated teardown
├── docs/
│   └── screenshots/
└── architecture/
    └── architecture-diagram.png
```

---

## CI/CD pipeline

```
push to main
     │
     ▼
┌─────────────────────────────────────────────────────┐
│ infra-ci.yml                                        │
│  terraform fmt · validate · plan                    │
│  Checkov (IaC security)                             │
│  Trivy (config · secrets · image CVEs)              │
│  ansible-lint                                       │
└─────────────────────────────────────────────────────┘
     │  on success
     ▼
┌─────────────────────────────────────────────────────────┐
│ infra-deploy.yml                                        │
│  ⏸  waits for manual approval (GitHub Environment)     │
│  terraform apply                                        │
│  generate Ansible inventory from live outputs           │
│  ansible-playbook (configure + deploy app + monitoring) │
└─────────────────────────────────────────────────────────┘
```

Validation and security scanning run automatically and unattended on every push — fast feedback. **Actual infrastructure changes require a human to click "Approve"** in GitHub's Environment protection UI before Terraform touches Azure, mirroring how production platform teams gate infrastructure risk separately from code risk. `destroy.yml` uses the same approval gate, since teardown is equally high-stakes.

---

## Security

- **SSH:** key-only authentication (password auth disabled), root login disabled, `MaxAuthTries` limited, restricted to a single dynamically-resolved administrator IP
- **Zero public exposure for the database tier:** no public IP; reachable only via SSH jump through the web server
- **Network segmentation:** PostgreSQL (5432) accepts connections only from the application subnet, never the internet
- **Encrypted secrets at rest:** database and Grafana credentials encrypted with Ansible Vault (AES-256), never committed in plaintext
- **Defense in depth:** firewall rules enforced independently at two layers — Azure NSGs (network) and UFW (host) — so a misconfiguration in one layer doesn't remove protection entirely
- **Brute-force protection:** fail2ban bans repeat failed authentication attempts automatically
- **Shift-left scanning in CI:** Checkov scans every Terraform change for CIS-aligned misconfigurations; Trivy scans the application image for HIGH/CRITICAL CVEs and the full repository for accidentally committed secrets (hard CI failure on any secret match — no exceptions)

---

## Monitoring

Prometheus and Grafana run on the web server and scrape Node Exporter (deployed via Ansible on both hosts) for CPU, memory, disk, and network metrics. The Grafana datasource and the community "Node Exporter Full" dashboard are provisioned declaratively on container startup — no manual dashboard clicking. Prometheus is bound to `127.0.0.1` only (no built-in auth); Grafana is exposed on port 3000, restricted at the NSG layer to the administrator's IP.

---

## Running it yourself

Requires: Terraform ≥1.15, Ansible ≥2.15, an Azure subscription, and Docker (for local image builds).

```bash
# 1. Provision infrastructure
cd terraform
terraform init
terraform apply

# 2. Generate a live Ansible inventory from Terraform outputs
cd ../scripts
./generate-inventory.sh

# 3. Configure both servers, deploy the app, and stand up monitoring
cd ../ansible
ansible-playbook playbook.yml --ask-vault-pass
```

---

##### Author: Emna Chebbi
