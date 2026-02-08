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


или
 ~/.aws/credentials записываем ключи  

[default]
aws_access_key_id = XXXXXXXXXXXXXXXX  
aws_secret_access_key = YYYYYYYYYYYYYYYYYYYY  
и не ужно каждый раз экспортировать


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


# 4 Проверка bucket
Файл terraform.tfstate теперь храниться в bucket

Также можно включить версионирование в bucket
![Рисунок 4](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_4.jpg) 

Можно просмотреть версии файла
![Рисунок 20](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_20.jpg) 
------


## 1. Создаем сервера для кластера 
Создаем одну мастер ноду и две рабочих
![созданире инфраструктуры](https://github.com/ysatii/devops-diplom-yandexcloud/tree/main/terraform/infra)

Команды для создания бакета  
```
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

├── backend.tf               - бакет для хранения файла состояния   
├── compute.tf               - создаем мастре и воркеры  
├── inventory.tf             - генерирует инвентору  
├── inventory.tftpl          - шаблон для генерации инвентори  
├── locals.tf                - описывает зоны для размещения серверов  
├── meta.txt                 - мета содержимое для создание виртуальных машин  
├── networks.для кластера tf - описывает сеть и подсети  
├── outputs.tf               - внешншние и внутренные ип адреса серверов  
├── providers.tf             - описан провайлдер яндекс  
├── security.tf              - группы бесзопастности  
├── variables.tf             - переменные и описание диапозонов под сетей  
└── versions.tf              - версия провайдера яндекс и local  



Получили ip адреса машин  
![Рисунок 6](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_6.jpg) 

Можем посмотреть версии terraform.tfstate
![Рисунок 7](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_7.jpg) 

Посмотрим в консоли какие машины создались 
![Рисунок 8](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_8.jpg) 

Посмотрим сеть
![Рисунок 9](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_9.jpg) 

Внешние Ип адреса
![Рисунок 10](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_10.jpg) 

Сервисные аккаунты
![Рисунок 11](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_11.jpg) 

Подсети сети k8s-net
![Рисунок 12](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_12.jpg) 

Файл с спискаси ип адресов мастер ноды и воркеров
[инвентори файл](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/terraform/kubespray/inventory/my-k8s-cluster/hosts.yml)

```
all:
  vars:
    ansible_user: lamer

  hosts:
    k8s-master-1:
      ansible_host: 51.250.65.222
      ip: 10.0.1.7
      access_ip: 10.0.1.7

    k8s-worker-1:
      ansible_host: 89.169.136.241
      ip: 10.0.1.34
      access_ip: 10.0.1.34
    k8s-worker-2:
      ansible_host: 89.169.191.144
      ip: 10.0.2.9
      access_ip: 10.0.2.9
    k8s-worker-3:
      ansible_host: 158.160.200.180
      ip: 10.0.3.16
      access_ip: 10.0.3.16

  children:
    kube_control_plane:
      hosts:
        k8s-master-1:
    kube_node:
      hosts:
        k8s-worker-1:
        k8s-worker-2:
        k8s-worker-3:
    etcd:
      hosts:
        k8s-master-1:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
```