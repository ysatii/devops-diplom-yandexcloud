terraform {
  backend "s3" {
    endpoint                    = "https://storage.yandexcloud.net"
    bucket                      = "bucket-terraform-save1"
    key                         = "infra/terraform.tfstate"
    region                      = "ru-central1"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
  }
}