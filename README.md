# saviynt-iac

> Infrastructure as Code (IaC) for managing [Saviynt Identity Cloud](https://saviynt.com) resources using Terraform.

---

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Modules](#modules)
  - [security\_systems\_standard](#security_systems_standard)
  - [security\_systems\_sap](#security_systems_sap)
  - [end\_points](#end_points)
  - [connections/ad\_connection](#connectionsad_connection)
- [Environments](#environments)
  - [dev](#dev)
- [CSV Inventory Files](#csv-inventory-files)
- [Getting Started](#getting-started)
- [Variables Reference](#variables-reference)
- [Security & Secrets Management](#security--secrets-management)
- [Known Limitations](#known-limitations)
- [Contributing](#contributing)

---

## Overview

This repository provides a modular, CSV-driven Terraform configuration for provisioning and managing Saviynt Identity Cloud resources. Instead of hardcoding individual resources, all inventory (security systems, endpoints, and connections) is defined in CSV files under each environment. Terraform reads these files at plan/apply time and creates resources dynamically using `for_each`.

**Resources managed:**
- Security Systems (Standard and SAP)
- Endpoints
- ADSI Connections (AD, ADSI)

---

## Project Structure

```
saviynt-iac/
├── .gitignore
├── README.md
├── environments/
│   └── dev/
│       ├── main.tf                          # Root module — provider, locals, module calls
│       ├── variables.tf                     # Environment-level input variables
│       ├── terraform.tfvars                 # ⚠️ Local only, never commit (gitignored)
│       └── data/
│           ├── inventory_systems.csv        # Security system inventory
│           ├── inventory_endpoints.csv      # Endpoint inventory
│           └── inventory_adsi_connections.csv  # ADSI connection inventory
└── modules/
    ├── security_systems_standard/           # Standard security system (AD, ADSI, etc.)
    │   └── resource.tf
    ├── security_systems_sap/                # SAP security system
    │   └── resource.tf
    ├── end_points/                          # Endpoint resource
    │   └── resource.tf
    └── connections/
        └── ad_connection/                   # ADSI connection resource
            └── resource.tf
```

---

## Prerequisites

| Requirement | Version |
|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/install) | `>= 1.3` (recommend `>= 1.11` for write-only attributes) |
| [Saviynt Terraform Provider](https://registry.terraform.io/providers/saviynt/saviynt/latest) | `>= 0.3.3` |
| Saviynt Identity Cloud instance | With API access enabled |

Install Terraform:
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

---

## Modules

### `security_systems_standard`

Creates a standard Saviynt Security System — used for AD, ADSI, and other non-SAP connector types.

**Input Variables:**

| Variable | Type | Description |
|---|---|---|
| `security_system_name` | `string` | Unique name for the security system |
| `sec_display_name` | `string` | Display name shown in Saviynt UI |
| `sec_description` | `string` | Description for the security system |

---

### `security_systems_sap`

Creates a SAP-specific Saviynt Security System.

**Input Variables:**

| Variable | Type | Description |
|---|---|---|
| `security_system_name` | `string` | Unique name for the SAP security system |
| `sec_display_name` | `string` | Display name shown in Saviynt UI |
| `sec_description` | `string` | Description for the security system |

---

### `end_points`

Creates Saviynt Endpoints linked to their parent security systems. Accepts a map of endpoints driven from a CSV file.

**Input Variables:**

| Variable | Type | Description |
|---|---|---|
| `endpoints` | `map(any)` | Map of endpoint objects decoded from CSV |

> **Note:** This module uses `depends_on` against both `sec_system_std` and `sec_system_sap` to ensure the parent security systems exist before endpoints are created.

---

### `connections/ad_connection`

Creates a fully configured `saviynt_adsi_connection_resource` in Saviynt. This module covers the complete provisioning lifecycle including:

- User and account import attribute mappings
- Account create / update / enable / disable / remove
- Group create / update / remove
- Add / remove access (user-to-group and group-to-group)
- Service account create / update / remove
- Password reset
- Status threshold configuration
- Custom connection timeout config

**Input Variables:**

| Variable | Type | Sensitive | Description |
|---|---|---|---|
| `adsi_connection_name` | `string` | No | Unique name for the ADSI connection |
| `adsi_email_template` | `string` | No | Email template for notifications (default: `Account Password Expiry Email`) |
| `LDAP_PROTOCOL` | `string` | No | Protocol — `ldap` or `ldaps` |
| `IP_ADDRESS` | `string` | No | Hostname or IP of the AD/ADSI server |
| `PASSWORD` | `string` | **Yes** | Bind account password |
| `BIND_USER` | `string` | No | Bind account username (DN format) |
| `CONNECTION_URL` | `string` | No | Primary connection URL |
| `PROVISIONING_URL` | `string` | No | Provisioning URL |
| `VAULT_CONNECTION` | `string` | No | Vault connection name (e.g. `Hashicorp`) |
| `VAULT_CONFIG` | `string` | No | JSON vault path/key mapping config |
| `SAVE_IN_VAULT` | `string` | No | `"true"` or `"false"` |

---

## Environments

### `dev`

The `dev` environment is the entry point for running Terraform. It reads CSV inventory files and instantiates all modules using `for_each`.

**Module execution order:**
```
1. sec_system_std   — Standard security systems (non-SAP)
2. sec_system_sap   — SAP security systems
3. endpoints        — Endpoints (depends on both system modules)
4. adsi_connections — ADSI connections (optionally depends on endpoints)
```

**Provider configuration** is declared here — do not duplicate the `terraform {}` or `provider "saviynt"` blocks in child modules.

---

## CSV Inventory Files

All resources are data-driven via CSV files located in `environments/dev/data/`. This makes it easy to onboard new systems, endpoints, or connections without touching any Terraform code — just add a new row to the relevant CSV.

### `inventory_systems.csv`

```csv
key,security_system_name,sec_display_name,sec_description,type
sys_001,MY_AD_SYSTEM,My AD System,Active Directory System,AD
sys_002,MY_SAP_SYSTEM,My SAP System,SAP ECC System,SAP
```

> The `type` column controls whether a row goes to `sec_system_std` (non-SAP) or `sec_system_sap` (SAP).

### `inventory_endpoints.csv`

```csv
key,endpoint_name,endpoint_displayname,security_system
ep_001,MY_AD_ENDPOINT,My AD Endpoint,MY_AD_SYSTEM
```

### `inventory_adsi_connections.csv`

```csv
key,LDAP_PROTOCOL,IP_ADDRESS,BIND_USER,CONNECTION_URL,PROVISIONING_URL
conn_001,ldaps,ad.example.com,CN=svc_acct,DC=example,DC=com,ldaps://ad.example.com,ldaps://ad.example.com
```

> Passwords are **never** stored in CSV files. They are passed via `var.connection_passwords` — a sensitive `map(string)` variable keyed by the connection's `key` value.

---

## Getting Started

**1. Clone the repository**
```bash
git clone https://github.com/vineetgupta007/saviynt-iac.git
cd saviynt-iac/environments/dev
```

**2. Create your `terraform.tfvars`**
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your Saviynt instance details:
```hcl
SAVIYNT_SERVER_URL = "https://my-tenant.saviyntcloud.com"
saviynt_username   = "admin"
saviynt_password   = "your-password"

connection_passwords = {
  conn_001 = "your-adsi-bind-password"
}
```

> ⚠️ `terraform.tfvars` is gitignored. Never commit it.

**3. Populate your CSV inventory files** in `environments/dev/data/` as described above.

**4. Initialise Terraform**
```bash
terraform init
```

**5. Preview the plan**
```bash
terraform plan
```

**6. Apply**
```bash
terraform apply
```

---

## Variables Reference

These variables must be declared in `environments/dev/variables.tf`:

| Variable | Type | Sensitive | Description |
|---|---|---|---|
| `SAVIYNT_SERVER_URL` | `string` | No | Base URL of your Saviynt EIC instance |
| `saviynt_username` | `string` | No | Saviynt admin username |
| `saviynt_password` | `string` | **Yes** | Saviynt admin password |
| `connection_passwords` | `map(string)` | **Yes** | Map of connection key → bind password |

---

## Security & Secrets Management

- **Never commit `terraform.tfvars`** — it is gitignored by default.
- **Never commit `terraform.tfstate`** — consider using a remote backend (e.g. Terraform Cloud, S3) for team use.
- Passwords in the `ad_connection` module currently use the `password` attribute, which is marked `sensitive = true` but is **stored in Terraform state**. For enhanced security, migrate to `password_wo` + `wo_version` (requires Terraform `>= 1.11`).
- Vault integration is supported via `VAULT_CONNECTION` and `VAULT_CONFIG` — use this in production environments to avoid storing credentials in state at all.

**Recommended `.gitignore` entries:**
```
*.tfvars
*.tfstate
*.tfstate.backup
.terraform/
.terraform.lock.hcl
```

---

## Known Limitations

- `terraform destroy` is **not supported** for some Saviynt resources (e.g. Security Systems, Endpoints). Refer to the [Saviynt provider docs](https://registry.terraform.io/providers/saviynt/saviynt/latest/docs) for the current list.
- Manual changes made in the Saviynt UI (outside Terraform) will **not** be detected as drift for some resource types.
- The `MappedEndpoints` field on endpoints cannot be set during initial creation — it must be managed after the endpoint exists.
- The `ad_connection` module folder name implies AD REST but uses `saviynt_adsi_connection_resource` (ADSI). Rename to `adsi_connection` if adding a true AD REST module later to avoid confusion.

---

## Contributing

1. Create a feature branch: `git checkout -b feature/my-change`
2. Make your changes and test with `terraform plan` from `environments/dev/`
3. Open a pull request with a clear description of what changed and why

---

*Maintained by [@vineetgupta007](https://github.com/vineetgupta007)*
