output "service_account" {
  value = google_service_account.devops.email
}

output "workload_identity_provider" {
  value = "projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.workload_identity_pool_id}/providers/github"
}
