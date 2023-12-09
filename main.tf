locals {
  name_slug = replace(replace(lower(var.name), "/\\W|_|\\s/", "-"), "/-+/", "-")
}

resource "google_compute_address" "server_public_ip" {
  address_type = "EXTERNAL"
  name         = "pip-${local.name_slug}"
  network_tier = "STANDARD"
}

resource "google_service_account" "server_service_account" {
  account_id = local.name_slug
}

resource "google_compute_disk" "additional_volumes" {
  for_each = var.additional_volumes

  name = "stg-${local.name_slug}-data-${each.value.name}"
  size = each.value.size
  type = each.value.type == null ? "pd-standard" : each.value.type
}

resource "google_compute_instance" "server_instance" {
  deletion_protection       = false
  can_ip_forward            = false
  enable_display            = false
  labels                    = {}
  machine_type              = var.instance_type
  name                      = local.name_slug
  allow_stopping_for_update = true
  tags                      = var.network_tags
  boot_disk {
    auto_delete = true

    initialize_params {
      image  = var.instance_image
      labels = {}
      size   = var.volume_size
      type   = "pd-standard"
    }
  }

  network_interface {
    network            = var.network
    subnetwork         = var.subnet
    subnetwork_project = var.project

    access_config {
      nat_ip       = google_compute_address.server_public_ip.address
      network_tier = "STANDARD"
    }
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  service_account {
    email = google_service_account.server_service_account.email
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }
}

resource "google_compute_attached_disk" "additional_volumes" {
  for_each = var.additional_volumes

  disk     = google_compute_disk.additional_volumes[each.key].id
  instance = google_compute_instance.server_instance.id
}
