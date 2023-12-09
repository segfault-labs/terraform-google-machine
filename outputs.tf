output "public_ip" {
  value = google_compute_address.server_public_ip.address
}

output "name" {
  value = google_compute_instance.server_instance.name
}
