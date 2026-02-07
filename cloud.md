[Главная](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/task.md) 

# Создаем инфраструктуру 
## 1. Создаем bucket  
 (https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/terraform/backet/bucket.tf)
 
```
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

Структура 
├── bucket.tf                   - создание бакета 
├── providers.tf                - описан провайдер яндекс   
├── service-account.tf          - создаем сервисный аккаунт для работы с ресурсами
├── variables.tf                - идентификаторы облака
└── versions.tf                 - версия провайдера яндекс




## 2. Использование бакета для храниения файла сотояния  terraform
необходимо  экспортировать ключ AWS_ACCESS_KEY_ID и AWS_SECRET_ACCESS_KEY в терминал 
  ```
  export AWS_ACCESS_KEY_ID=$(terraform output -raw sa_access_key)
  export AWS_SECRET_ACCESS_KEY=$(terraform output -raw sa_secret_key)
  ```

## 3 В папке для создания серверов кластера создаем файл /backend.tf
листинг terraform/infra/backend.tf
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


# 4 файл terraform.tfstate теперь храниться в bucket

также можно включить версионирование в bucket

------
