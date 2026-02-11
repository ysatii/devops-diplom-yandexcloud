[Главная](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/task.md) 

# Репозиторий для приложения 
[репозиторий c приложением https://github.com/ysatii/devops-diplom-app-nginx](https://github.com/ysatii/devops-diplom-app-nginx) согласно задания!
```
git clone git@github.com:ysatii/devops-diplom-app-nginx.git
```

## Собираем образ 

Находясь в папке с Dockerfile:

```
cd devops-diplom-app-nginx/test-app-nginx
docker build -t devops-diplom-app-nginx:local .
docker tag devops-diplom-app-nginx:local cr.yandex/crppb66e9i1ff7ch71d2/devops-diplom-app-nginx:v1
```

Проверка

```
docker images | grep devops-diplom-app-nginx
```
![Рисунок 21](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_21.jpg) 

## docker login с токеном из tfvars
Создаем Registry [terraform/infra/yandex_container_registry.tf](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/terraform/infra/yandex_container_registry.tf)

Создаем сервис аккаунт , для рабты с регестри [terraform/infra/service-account.tf](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/terraform/infra/service-account.tf)  

```
cd devops-diplom-yandexcloud/terraform/infra
 

OAUTH_TOKEN=$(grep -E '^\token\s*=' personal.auto.tfvars | sed -E 's/.*"([^"]+)".*/\1/')
echo "$OAUTH_TOKEN" | docker login --username oauth --password-stdin cr.yandex
````


перетегируем и запушим в репозиторий 
```
docker tag devops-diplom-app-nginx:local cr.yandex/crppb66e9i1ff7ch71d2/devops-diplom-app-nginx:v1
docker push cr.yandex/crppb66e9i1ff7ch71d2/devops-diplom-app-nginx:v1   

```


![Рисунок 22](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_22.jpg) 
![Рисунок 23](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_23.jpg) 
![Рисунок 24](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_24.jpg) 

registry_id = "crppb66e9i1ff7ch71d2" присутвует в выводе terraform

![Рисунок 25](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_25.jpg) 


# Деплой тестового приложения
