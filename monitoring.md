[Главная](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/task.md) 

# Мониторинг

## Шаг 1 — ставим kube-prometheus-stack (Prometheus + Grafana)
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create ns monitoring --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack -n monitoring
```

в реальном времени
```
kubectl -n monitoring get pods -w
```

или просто вывод 
```
kubectl -n monitoring get pods -w
```
![Рисунок 29](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_29.jpg) 

## Шаг 2 — Создададим сервис для Grafana через NodePort

файл k8s/monitoring/grafana-nodeport.yaml:
```
apiVersion: v1
kind: Service
metadata:
  name: monitoring-grafana-nodeport
  namespace: monitoring
spec:
  type: NodePort
  selector:
    app.kubernetes.io/name: grafana
    app.kubernetes.io/instance: monitoring
  ports:
    - name: http
      port: 80
      targetPort: 3000
      nodePort: 30090
```

Применяем:
```
kubectl apply -f k8s/monitoring/grafana-nodeport.yaml
kubectl -n monitoring get svc | grep grafana
```


## Шаг 3 — пароль Grafana
Логин: admin
```
kubectl -n monitoring get secret monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d; echo
```
![Рисунок 30](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_30.jpg) 


## Шаг 4 — проверка

Открываем
Grafana: http://<PUBLIC_IP_любой_ноды>:30090
Видим графану на всех нодах!

![Рисунок 31](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_31.jpg) 
![Рисунок 32](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_32.jpg) 
![Рисунок 33](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_33.jpg) 

![Рисунок 34](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_34.jpg) 

После установки можно проверить что есть в пространстве имен monitoring

```
kubectl -n monitoring get daemonsets
```
Выывод команды видим три реплики monitoring-prometheus-node-exporter 
```
monitoring-prometheus-node-exporter   3         3         3       3            3           kubernetes.io/os=linux   17m
```

Псомотрим на каких нодах 
```
kubectl -n monitoring get pods -o wide | grep node-exporter
```
Вывод команды
```
monitoring-prometheus-node-exporter-htznh                1/1     Running   0          17m   10.0.1.26        k8s-master-1   <none>           <none>
monitoring-prometheus-node-exporter-z9k6q                1/1     Running   0          17m   10.0.1.19        k8s-worker-1   <none>           <none>
monitoring-prometheus-node-exporter-zfh9k                1/1     Running   0          17m   10.0.2.28        k8s-worker-2   <none>           <none>
```
Убеждаемся что на каждой ноде есть exporter


## Шаг 5 — проверка
мониторинг кластера
Grafana: http://<PUBLIC_IP_любой_ноды>:30090
Перейти  Dashboards
Самые важные дашборды

### Kubernetes / Compute Resources / Cluster
Общая картина по кластеру
![Рисунок 35](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_35.jpg)

### Kubernetes / Compute Resources / Node
CPU, RAM, Load по каждой ноде
![Рисунок 36](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_36.jpg) 

### Kubernetes / Compute Resources / Namespace
Использование ресурсов по namespace testapp
![Рисунок 37](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_37.jpg) 

###  Kubernetes / Compute Resources / Pod
Метрики pod'ов
![Рисунок 38](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_38.jpg) 
