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

output "registry_id" {
  value = yandex_container_registry.test.id
}

output "cr_service_account_name" {
  description = "Service account name for Container Registry"
  value       = yandex_iam_service_account.cr_sa.name
}

output "cr_service_account_id" {
  description = "Service account ID for Container Registry"
  value       = yandex_iam_service_account.cr_sa.id
}

output "cr_service_account_key_id" {
  description = "IAM key ID for Container Registry"
  value       = yandex_iam_service_account_key.cr_sa_key.id
}

output "cr_service_account_private_key" {
  description = "Private key for IAM token generation"
  value       = yandex_iam_service_account_key.cr_sa_key.private_key
  sensitive   = true
}

