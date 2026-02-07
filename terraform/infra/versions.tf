terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.68.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
  }
}
