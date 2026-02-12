[Главная](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/task.md) 

мШаг 1 — ставим kube-prometheus-stack (Prometheus + Grafana)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create ns monitoring --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack -n monitoring


Ждём:

kubectl -n monitoring get pods -w

Шаг 2 — откроем Grafana тоже через NodePort (как мы сделали с приложением)

Создай файл k8s/monitoring/grafana-nodeport.yaml:

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


Применяем:

kubectl apply -f k8s/monitoring/grafana-nodeport.yaml
kubectl -n monitoring get svc | grep grafana

Шаг 3 — пароль Grafana
kubectl -n monitoring get secret monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d; echo


Логин: admin

Шаг 4 — проверка

Открываем

Grafana: http://<PUBLIC_IP_любой_ноды>:30090

Твоё приложение: http://<PUBLIC_IP_любой_ноды>:30080