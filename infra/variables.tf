variable "project_id" {
  type        = string
  nullable    = false
  description = "GCP project ID where resources will be created"
}

variable "workload_identity_pool_id" {
  type        = string
  description = "ID of the workload identity pool for GitHub Actions authentication"
}

variable "repository" {
  type        = string
  nullable    = true
  description = "GitHub repository in OWNER/REPO format (optional, for GitHub Actions access control)"
}

variable "region" {
  type        = string
  description = "GCP region for resource deployment"
}

variable "gcr_name" {
  type        = string
  description = "Artifact Registry repository name"
}

variable "vm" {
  type = object({
    name         = string
    location     = string
    machine_type = string
    disk_size    = number
    disk_type    = string
    image        = string
    tags         = list(string)
  })
  description = "Compute VM configuration including machine type, disk settings, image, and SSH access"
}

variable "docker_image_name" {
  type        = string
  default     = "web"
  description = "Name of the Docker image to pull from Artifact Registry"
}

variable "cloudflare_token" {
  type        = string
  sensitive   = true
  description = "Cloudflare API token for DNS management"
}

variable "base_domain_name" {
  type        = string
  sensitive   = true
  description = "Base domain name for PR preview deployments"
}

variable "container_port" {
  type        = number
  description = "Port number the application container listens on"
  default     = 80
}
