resource "google_compute_instance" "app" {
  boot_disk {
    auto_delete = true
    device_name = var.vm.name

    initialize_params {
      image = var.vm.image
      size  = var.vm.disk_size
      type  = var.vm.disk_type
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = var.vm.machine_type
  name         = var.vm.name

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/${var.project_id}/regions/${var.region}/subnetworks/default"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  service_account {
    email  = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true
  tags                      = var.vm.tags
  zone                      = var.vm.location
  metadata_startup_script   = <<EOF
  sudo apt update
  sudo apt install -y curl docker.io docker-cli jq nginx gettext certbot python3-certbot-dns-cloudflare
  sudo systemctl start docker
  sudo mkdir -p /opt/devops/{scripts,templates}
  sudo curl -fsSL -o /opt/devops/scripts/deploy.sh https://gist.githubusercontent.com/tbhaxor/fd7ba86dd45ab1f02c408bbe5d1412aa/raw/06100e058bd66622b88fa8e0015463dbf4acc30c/deploy.sh
  sudo chmod +x /opt/devops/scripts/deploy.sh
  sudo curl -fsSL -o /opt/devops/templates/nginx.conf https://gist.githubusercontent.com/tbhaxor/fd7ba86dd45ab1f02c408bbe5d1412aa/raw/95ae9d80187895f6cc2bae1f27de43663df9a6e7/nginx.conf
  EOF
  metadata = {
    artifact-registry-name  = google_artifact_registry_repository.my-repo.repository_id
    docker-image-name       = var.docker_image_name
    base-domain-name        = var.base_domain_name
    container-port          = var.container_port
    cloudflare-access-token = var.cloudflare_token # TODO: Use secret manager
  }
}
