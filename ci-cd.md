[Главная]

# CI/CD

Репозиторий GitLab, используемый для реализации CI/CD:  
https://gitlab.com/yurii_melnik/devops-diplom-ci-cd
**На бесплатном тарифном плане GitLab отсутствует возможность автоматического Pull-mirroring репозиториев из https://github.com, поэтому репозиторий размещён непосредственно в GitLab.**

## Первая стадия — Build

При выполнении push в ветку `main` автоматически запускается pipeline.

В рамках стадии сборки:

- выполняется сборка Docker-образа на основе [Dockerfile](https://github.com/ysatii/devops-diplom-app-nginx/blob/main/test-app-nginx/Dockerfile)
- образ получает версию в формате `v1.N`
- собранный образ публикуется в Yandex Container Registry

## Вторая стадия — Deploy

После успешной сборки выполняется автоматическое развертывание:

- Kubernetes Deployment обновляется на новую версию образа
- выполняется rolling update без остановки сервиса

В результате каждая новая версия приложения автоматически разворачивается в кластере после изменения исходного кода.



### Что нужно для CI/CD
Компоненты

- Git репозиторий с приложением  
- Yandex Container Registry (YCR) — куда пушим образы
- Kubernetes кластер — куда деплоим (namespace testapp, deployment testapp)
- GitLab CI pipeline (файл .gitlab-ci.yml в корне репозитория)

## Файл .gitlab-ci.yml (что должен делать)
[.gitlab-ci.yml](https://github.com/ysatii/devops-diplom-app-nginx/blob/main/.gitlab-ci.yml)
Pipeline состоит из 2 стадий:
- Build
собирает Docker-образ через Kaniko (без docker-in-docker)
пушит в YCR

- Deploy
берёт kubeconfig из переменной
выполняет kubectl set image …
ждёт rollout

## Версионирование образов (v1.1, v1.2…)

тег:
v1.${CI_PIPELINE_IID}

Это даёт:
v1.1, v1.2, v1.3… автоматически

каждый запуск пайплайна → новый тег → Kubernetes точно обновит pods
В .gitlab-ci.yml:
```
variables:
  IMAGE_TAG: "v1.${CI_PIPELINE_IID}"
  IMAGE: "$YCR_IMAGE:$IMAGE_TAG"
```

![Рисунок 39](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_39.jpg) 


## Переменные GitLab CI/CD (сколько и какие)
### Нужно 3 переменные:

### YCR_IMAGE
Что это: путь к репозиторию образов в YCR (без тега)
cr.yandex/crpau2lnc3tnhv1ga4g8/devops-diplom-app-nginx

### YC_OAUTH_TOKEN

это: OAuth токен Yandex Cloud для push в YCR.
Используется Kaniko для авторизации в cr.yandex.

### KUBE_CONFIG_B64
ubeconfig администратора кластера (admin.conf), закодированный в base64 одной строкой.

![Рисунок 40](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_40.jpg) 

### Где и как завести переменные в GitLab

Project → Settings → CI/CD → Variables → Add variable

Для каждой переменной:
Key = имя
Value = значение
Masked =  (можно)
 

### kubeconfig: где взять файл и что в нём поправить
Где лежит на master
На master-ноде:
/etc/kubernetes/admin.conf
![Рисунок 41](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_41.jpg) 

Как забрать себе 
На master:
```
sudo cp /etc/kubernetes/admin.conf /home/lamer/k8s-admin.conf
sudo chown lamer:lamer /home/lamer/k8s-admin.conf
```

На своей машине:
```
scp lamer@89.169.135.209:/home/lamer/k8s-admin.conf .
```
### В kubeconfig нужно отключить сертификаты (TLS verify)

Потому что сертификат API выдан на внутренние IP, а CI ходит по внешнему.
В файле k8s-admin.conf должно быть:
```
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://93.77.181.183:6443
```

То есть:
server: должен быть внешний IP мастера
insecure-skip-tls-verify: true — включён

### Как сделать KUBE_CONFIG_B64

На своей машине:
```
base64 -w 0 k8s-admin.conf > kube_b64.txt
```

Открываем kube_b64.txt, копируем строку целиком и вставляешь в переменную KUBE_CONFIG_B64.

![Рисунок 42](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_42.jpg) 




## Как pipeline использует kubeconfig

В deploy job:
```
mkdir -p ~/.kube
printf '%s' "$KUBE_CONFIG_B64" | base64 -d > ~/.kube/config
```

Важно использовать printf, чтобы строка не ломалась.

## Итоговый результат CI/CD

После каждого коммита:
собирается новый образ и пушится в YCR с тегом v1.N
деплой обновляет deployment в Kubernetes на этот тег
Kubernetes делает rolling update

[файл с.gitlab-ci.yml](https://gitlab.com/yurii_melnik/devops-diplom-ci-cd/-/blob/main/.gitlab-ci.yml)

## Информация о подах до примения CI/CD

```
kubectl get pods -n testapp
kubectl -n testapp get pod testapp-75c4f9c6f7-z9w4s -o jsonpath='{.spec.containers[*].image}'
```

Версия образа
cr.yandex/crpau2lnc3tnhv1ga4g8/devops-diplom-app-nginx:v1.12

приложение имеет версию 3!
![Рисунок 43](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_43.jpg) 

Изменям на версию 4 ! 
изменили файл [index.html](https://gitlab.com/yurii_melnik/devops-diplom-ci-cd/-/blob/main/test-app-nginx/index.html?ref_type=heads)
Делаем push в репозиторий 
![Рисунок 44](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_44.jpg) 
![Рисунок 45](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_45.jpg) 
![Рисунок 46](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_46.jpg) 

обновление произошло ! 
![Рисунок 47](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_47.jpg) 


