[Главная](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/task.md) 

# установка кластера 
## Склонируем Kubespray (правильная версия)
в корне проекта devops-diplom-yandexcloud
```
git clone https://github.com/kubernetes-sigs/kubespray.git
cp -r terraform/kubespray/inventory/my-k8s-cluster kubespray/inventory/
```


Должен быть hosts.yml.
```
ls kubespray/inventory/my-k8s-cluster
```

## проверим корректность инвентори файла
```
cd kubespray
ansible-inventory -i inventory/my-k8s-cluster/hosts.yml --list | sed -n '1,40p'
```
![Рисунок 13](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_13.jpg) 

Если команда не ругается — inventory валидный.

## Пинг всех нод
```
ansible -i inventory/my-k8s-cluster/hosts.yml all -m ping
```
![Рисунок 14](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_14.jpg) 


 
## Подготовка зависимостей Kubespray (важный шаг)

Внутри kubespray почти всегда надо поставить python-зависимости:
```
python3 -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -r requirements.txt
```

у меня возникли ошибки! на других машиназх могут быть другие ошибки или все нормально пройдет
я привел requirements.txt к виду
```
# ansible==10.7.0
ansible-core==2.13.13


# Needed for community.crypto module
cryptography==46.0.4
# Needed for jinja2 json_query templating
jmespath==1.0.1
# Needed for ansible.utils.ipaddr
netaddr==1.3.0
```


Проверка:
```
ansible --version
ansible [core 2.13.13]
  config file = /home/lamer/Рабочий стол/devops-diplom-yandexcloud/kubespray/ansible.cfg
  configured module search path = ['/home/lamer/Рабочий стол/devops-diplom-yandexcloud/kubespray/library']
  ansible python module location = /home/lamer/Рабочий стол/devops-diplom-yandexcloud/kubespray/.venv/lib/python3.8/site-packages/ansible
  ansible collection location = /home/lamer/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/lamer/Рабочий стол/devops-diplom-yandexcloud/kubespray/.venv/bin/ansible
  python version = 3.8.10 (default, Mar 18 2025, 20:04:55) [GCC 9.4.0]
  jinja version = 3.1.6
  libyaml = True
```
 
Проверка
```
ansible -i inventory/my-k8s-cluster/hosts.yml all -m ping
```
![Рисунок 15](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_15.jpg) 
![Рисунок 16](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_16.jpg) 




===========================

Ты можешь запускать Kubespray.

Команда (ровно одна):

ansible-playbook -i inventory/my-k8s-cluster/hosts.yml -b -v

Шаги (делай ровно так)
1) Выйти из venv и удалить её
deactivate
rm -rf .venv
=====================
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.10 python3.10-venv python3.10-distutils
========
cd kubespray
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
=====================
ставим кластер 
ansible-playbook -i inventory/my-k8s-cluster/hosts.yml -b -v
====================
1) Быстрый тест через admin.conf
sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes -o wide


Если покажет ноды — всё ок.

Сделать нормально для пользователя lamer (чтобы kubectl get nodes работало без sudo)
mkdir -p ~/.kube
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
kubectl get nodes -o wide
===========================
Скачиваем kubeconfig с master на локальную машину

На локальной машине (VirtualBox), НЕ по SSH:
Зайди на master
ssh lamer@89.169.158.12

2️⃣ Скопируй файл в домашний каталог
sudo cp /etc/kubernetes/admin.conf /home/lamer/admin.conf
sudo chown lamer:lamer /home/lamer/admin.conf
chmod 600 /home/lamer/admin.conf

Теперь скачай с локальной машины
scp lamer@89.169.158.12:/home/lamer/admin.conf ~/k8s-admin.conf


(89.169.158.12 — внешний IP master, как у тебя)
==================
Открой файл локально и проверь server::

nano ~/k8s-admin.conf


Должно быть:

server: https://89.169.158.12:6443

export KUBECONFIG=~/k8s-admin.conf
kubectl get nodes -o wide
===============================
Что сделать

Открой kubeconfig на локальной машине:

nano ~/k8s-admin.conf


В секции clusters: добавь одну строку:

clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://89.169.158.12:6443


❗ И удали / закомментируй строку:

certificate-authority-data: ...


Итоговый кусок должен выглядеть примерно так:

clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://89.169.158.12:6443
  name: cluster.local


Сохрани файл.

Проверка
export KUBECONFIG=~/k8s-admin.conf
kubectl get nodes -o wide


👉 ДОЛЖНО ЗАРАБОТАТЬ СРАЗУ!

Далее проверим наш кластер
kubectl get nodes
kubectl get pods --all-namespaces
===========
cd ../terraform
terraform destroy -auto-approve