# Сервисный аккаунт для Container Registry
resource "yandex_iam_service_account" "cr_sa" {
  name        = "service-registry"
  description = "Service account for Yandex Container Registry (push/pull images)"
}

# Роли для работы с Container Registry (push/pull)
resource "yandex_resourcemanager_folder_iam_member" "cr_editor" {
  folder_id = var.folder_id
  role      = "container-registry.editor"
  member    = "serviceAccount:${yandex_iam_service_account.cr_sa.id}"
}

# (Опционально) если хочешь только pull-право вместо editor, используй:
# role = "container-registry.viewer"

# (Опционально) Создать ключ для сервисного аккаунта,
# чтобы потом получать IAM-токен и логиниться в docker/crane/CI
resource "yandex_iam_service_account_key" "cr_sa_key" {
  service_account_id = yandex_iam_service_account.cr_sa.id
  description        = "Key for service account to access YCR"
}


