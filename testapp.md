[Главная](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/task.md) 

# Репозиторий для приложения 
[репозиторий c приложением https://gitlab.com/yurii_melnik/devops-diplom-ci-cd.git](https://gitlab.com/yurii_melnik/devops-diplom-ci-cd.git) согласно задания!
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
```


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
### Для успешного деплоя нам нужно сделать секрет для regestry и добавить его в name space

## Вытащим токен из personal.auto.tfvars
```
cd devops-diplom-yandexcloud/terraform/infra
OAUTH_TOKEN=$(grep -E '^\s*token\s*=' personal.auto.tfvars | sed -E 's/.*"([^"]+)".*/\1/')
echo "$OAUTH_TOKEN"
```

## Docker login в YCR этим токеном
```
echo "$OAUTH_TOKEN" | docker login cr.yandex -u oauth --password-stdin
```

## Теперь secret
ВАЖНО: namespace testapp должен существовать!

```
kubectl create ns testapp --dry-run=client -o yaml | kubectl apply -f -
kubectl -n testapp create secret docker-registry ycr-secret --docker-server=cr.yandex --docker-username=oauth --docker-password="$OAUTH_TOKEN" --docker-email=none
```

Проверка:

kubectl -n testapp get secret ycr-secret

## Подключить secret в Deployment
```
[k8s/testapp/10-deployment.yaml](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/k8s/testapp/10-deployment.yaml)
 spec:
      imagePullSecrets:
        - name: ycr-secret   # <-- ВАЖНО: добавили secret
      containers:
        - name: testapp
          image: cr.yandex/crpau2lnc3tnhv1ga4g8/devops-diplom-app-nginx:v1
          imagePullPolicy: Always
          ports:
            - name: http
              containerPort: 80
```

## Деплой из корня проект devops-diplom-yandexcloud


```
kubectl apply -f k8s/testapp/
kubectl -n testapp get pods
```

Запущено две реплики тестового приложения
![Рисунок 26](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_26.jpg)  

Проверям рабту со всех машин кластера
![Рисунок 27](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_27.jpg) 

Ип адреса можем взять из вывода terraform
![Рисунок 28](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_28.jpg) 
