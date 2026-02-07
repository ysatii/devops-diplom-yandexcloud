output "master_public_ips" {
  value = [for i in yandex_compute_instance.master : i.network_interface[0].nat_ip_address]
}

output "worker_public_ips" {
  value = [for i in yandex_compute_instance.worker : i.network_interface[0].nat_ip_address]
}

output "master_private_ips" {
  value = [for i in yandex_compute_instance.master : i.network_interface[0].ip_address]
}

output "worker_private_ips" {
  value = [for i in yandex_compute_instance.worker : i.network_interface[0].ip_address]
}
