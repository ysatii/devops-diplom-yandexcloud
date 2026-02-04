resource "yandex_storage_bucket" "netologybucket" {
  # авторизация операцией S3 — через ключи сервисного аккаунта servis-backet
  access_key = yandex_iam_service_account_static_access_key.sa_s3.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa_s3.secret_key
  acl = "private"
  bucket        = var.bucket_name
  force_destroy = "true"
}
