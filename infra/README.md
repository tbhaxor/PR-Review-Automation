# PR Review Automation Infrastructure

## Overview

This Terraform configuration provisions a GCP-based infrastructure for automating PR preview deployments. It sets up:

- **Service Accounts & Permissions**: Secure service account with minimal required permissions
- **Artifact Registry**: Container image repository for storing PR-specific Docker images
- **Compute Instance**: VM that runs Docker containers and hosts nginx reverse proxies
- **DNS & SSL/TLS**: Cloudflare DNS management and Let's Encrypt certificate provisioning for preview domains

## Architecture

When a PR is opened/updated:
1. GitHub Actions builds a Docker image tagged with the PR number
2. Image is pushed to Artifact Registry
3. A compute VM is provisioned with the image
4. A unique DNS record (`pr-<NUMBER>.domain.com`) is created via Cloudflare
5. SSL certificate is auto-provisioned using Let's Encrypt
6. NGINX reverse proxy routes traffic to the running container
7. Preview URL is posted as a PR comment

On PR close, all resources are cleaned up.

## Variables

| Variable | Type | Required | Description |
|----------|------|----------|-------------|
| `project_id` | `string` | ✓ | GCP project ID where resources will be created |
| `region` | `string` | ✓ | GCP region for resource deployment (e.g., `asia-south1`) |
| `workload_identity_pool_id` | `string` | ✓ | ID of the workload identity pool for GitHub Actions authentication |
| `repository` | `string` | ✗ | GitHub repository in `OWNER/REPO` format (optional, for restricting access) |
| `gcr_name` | `string` | ✓ | Artifact Registry repository name for storing Docker images |
| `docker_image_name` | `string` | ✗ | Docker image name to pull from Artifact Registry (default: `web`) |
| `base_domain_name` | `string` | ✓ | Base domain name for PR preview deployments (e.g., `preview.example.com`) |
| `cloudflare_token` | `string` | ✓ | Cloudflare API token for DNS management (sensitive) |
| `container_port` | `number` | ✗ | Port the application container listens on (default: `80`) |
| `vm` | `object` | ✓ | Compute VM configuration object with nested properties: |
| └ `vm.name` | `string` | ✓ | Name of the compute instance |
| └ `vm.location` | `string` | ✓ | Zone where VM will be deployed (e.g., `asia-south1-b`) |
| └ `vm.machine_type` | `string` | ✓ | GCP machine type (e.g., `e2-medium`) |
| └ `vm.disk_size` | `number` | ✓ | Disk size in GB |
| └ `vm.disk_type` | `string` | ✓ | Disk type (e.g., `pd-balanced`, `pd-standard`) |
| └ `vm.image` | `string` | ✓ | VM image URI from Google Cloud (e.g., Debian 13) |
| └ `vm.tags` | `list(string)` | ✓ | Network tags for firewall rules (e.g., `["http-server", "https-server"]`) |
| └ `vm.ssh` | `object` | ✓ | SSH configuration object: |

## Usage

### 1. Configure Variables

Create or update `terraform.tfvars`:

```hcl
project_id                  = "my-gcp-project"
region                      = "asia-south1"
workload_identity_pool_id   = "github-actions"
repository                  = "owner/repo"
gcr_name                    = "docker-images"
base_domain_name            = "preview.example.com"
cloudflare_token            = "your-cloudflare-api-token"

vm = {
  name         = "pr-review-vm"
  location     = "asia-south1-b"
  machine_type = "e2-medium"
  disk_size    = 50
  disk_type    = "pd-balanced"
  image        = "projects/debian-cloud/global/images/debian-13-trixie-v20251111"
  tags         = ["http-server", "https-server"]
  ssh = {
    username             = "debian"
    public_key_file_path = "~/.ssh/id_ed25519.pub"
  }
}
```

### 2. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

### 3. Configure GitHub Actions

Store the following as repository secrets/variables:
- `WORKLOAD_IDENTITY_PROVIDER_ID`: Full WIF provider ID
- `SERVICE_ACCOUNT`: Devops service account email
- `GCP_PROJECT_ID`: Your GCP project ID
- `REGION`: GCP region
- `ARTIFACT_REGISTRY_NAME`: Artifact Registry name
- `DOCKER_IMAGE_NAME`: Docker image name
- `BASE_DOMAIN_NAME`: Base domain for previews
- `VM_NAME`: Compute VM instance name
- `VM_ZONE`: VM zone
- `VM_DEPLOY_SCRIPT_PATH`: Path to `deploy.sh` on VM (e.g., `/opt/devops/deploy.sh`)

## Files

- `provider.tf` - GCP provider configuration
- `variables.tf` - Variable definitions
- `iam.tf` - Workload Identity, Service Accounts, and IAM roles
- `artifact_registry.tf` - Artifact Registry setup
- `compute.tf` - Compute VM instance definition

## Prerequisites

- Terraform >= 1.0
- GCP account with billing enabled
- Cloudflare account with API token
- GitHub repository with Actions enabled
