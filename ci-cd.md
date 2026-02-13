[Главная](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/task.md) 

## CI/CD
### Что нужно для CI/CD
Компоненты

- GitLab репозиторий с приложением  
- Yandex Container Registry (YCR) — куда пушим образы
- Kubernetes кластер — куда деплоим (namespace testapp, deployment testapp)
- GitLab CI pipeline (файл .gitlab-ci.yml в корне репозитория)

## Файл .gitlab-ci.yml (что должен делать)

Pipeline состоит из 2 стадий:
- Build
собирает Docker-образ через Kaniko (без docker-in-docker)
пушит в YCR

- Deploy
берёт kubeconfig из переменной
выполняет kubectl set image …
ждёт rollout

## Версионирование образов (v1.1, v1.2…)

Рекомендуемый тег:
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

Как забрать себе (вариант, который ты используешь)
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

Открываем kube_b64.txt, копируешь строку целиком и вставляешь в переменную KUBE_CONFIG_B64.

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