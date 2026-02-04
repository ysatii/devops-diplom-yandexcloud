[Главная](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/task.md) 
Создаем [bucket](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/terraform/backet/bucket.tf)
что бы хранить файл terraform.tfstate в бакете нужно 
- экспортировать ключ в терминал 
  ```
  export AWS_ACCESS_KEY_ID=$(terraform output -raw sa_access_key)
  export AWS_SECRET_ACCESS_KEY=$(terraform output -raw sa_secret_key)
  ```
и создать   backend.tf  
в terraform/infra/backend.tf
```
terraform {
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "bucket-terraform-save1"
    key                         = "infra/terraform.tfstate"
    region                      = "ru-central1"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
  }
}
```

также можно включить версионирование в bucket