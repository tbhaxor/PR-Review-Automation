data "google_project" "project" {
  project_id = var.project_id
}

resource "google_service_account" "devops" {
  account_id                   = "devops"
  display_name                 = "DevOps User"
  create_ignore_already_exists = true
}

resource "google_service_account_iam_binding" "workload_identity" {
  service_account_id = google_service_account.devops.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.workload_identity_pool_id}/attribute.repository/${var.repository}"
  ]
}

resource "google_project_iam_member" "artifact_registry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.createOnPushRepoAdmin"
  member  = "serviceAccount:${google_service_account.devops.email}"
}

resource "google_project_iam_member" "compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.devops.email}"
}

resource "google_project_iam_member" "service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.devops.email}"
}

resource "google_project_iam_member" "vm_artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}
