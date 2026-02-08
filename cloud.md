[Главная](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/task.md) 

# Создаем инфраструктуру 
## 1. Создаем bucket  
 (https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/terraform/backet/)
 
команды для создания бакета  
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


![Рисунок 1](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_1.jpg) 

![Рисунок 2](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_2.jpg) 




## 2. Использование бакета для храниения файла сотояния  terraform
необходимо  экспортировать ключ AWS_ACCESS_KEY_ID и AWS_SECRET_ACCESS_KEY в терминал 
  ```
  export AWS_ACCESS_KEY_ID=$(terraform output -raw sa_access_key)
  export AWS_SECRET_ACCESS_KEY=$(terraform output -raw sa_secret_key)
  ```
![Рисунок 3](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_3.jpg) 

![Рисунок 5](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_5.jpg)   

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
![Рисунок 4](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_4.jpg) 
------

## 1. Создаем сервера сервера
создаем одну мастер ноду и две рабочих

команды для создания бакета  
```
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

Получили ip адреса машин  
![Рисунок 6](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_6.jpg) 

Можем посмотреть версии terraform.tfstate
![Рисунок 7](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_7.jpg) 

Посмотрим в консоли какие машины создались 
![Рисунок 8](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_8.jpg) 

посмотрим сеть
![Рисунок 9](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_9.jpg) 
![Рисунок 10](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_10.jpg) 
![Рисунок 11](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_11.jpg) 
![Рисунок 12](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_12.jpg) 