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

у меня возникли ошибки! на других машиназх могут быть другие ошибки или все нормально пройдет!
у меня 20-я убунту! 
Как я запустил Kubernetes через Kubespray (что и зачем делал)

1. Проблема на старте

Kubespray не запускался вообще, потому что:
версия Ansible не совпадала с версией Kubespray;
Python был слишком старый (3.8);
часть Ansible collections отсутствовала;
inventory YAML сначала указывался не тем путём.

2. Приведение control-node в рабочее состояние
2.1 Python
На Ubuntu 20.04 нет нужного Python → использован pyenv
Python 3.10.13
ВАЖНО: Python сначала был собран без _ctypes, из-за отсутствия libffi-dev
```
sudo apt install -y libffi-dev build-essential
export PYTHON_CONFIGURE_OPTS="--with-system-ffi"
pyenv uninstall -f 3.10.13
pyenv install 3.10.13
```

Проверка:
```
python3.10 -c "import _ctypes; print('ctypes OK')"
```

3. Виртуальное окружение
Kubespray обязан работать в venv.
```
python3.10 -m venv .venv
source .venv/bin/activate
```

4. Ansible — ключевой момент
4.1 Kubespray требовал строго:
2.17.3 <= ansible-core < 2.18.0

Установлено:
```
pip install "ansible-core>=2.17.3,<2.18.0"
```

Проверка:
```
ansible --version
```
4.2 Почему requirements.txt нельзя ставить напрямую

В requirements.txt Kubespray жёстко зафиксирован ansible-core 2.13,
он ломает всё, если его поставить.
```
grep -vE '^ansible-core' requirements.txt > /tmp/req-no-ansible.txt
pip install -r /tmp/req-no-ansible.txt
```

5. Ansible Collections (без них Kubespray не живёт)

У Kubespray нет requirements.yml, только galaxy.yml (это metadata, не зависимости).

Поэтому коллекции ставились вручную:
```
ansible-galaxy collection install -f \
  ansible.posix \
  community.general \
  community.docker \
  kubernetes.core \
  ansible.utils \
  ansible.netcommon

```

Критичные:

kubernetes.core → Helm, k8s-модули

ansible.utils → ipaddr фильтр

ansible.posix → systemd, sysctl, mount

community.general → общие модули

6. Inventory (hosts.yml)
Формат: YAML (НЕ ini)

Файл:

inventory/my-k8s-cluster/hosts.yml


Проверка:
```
ansible-inventory -i inventory/my-k8s-cluster/hosts.yml --graph
```

Все группы (kube_control_plane, kube_node, etcd) определились корректно.

7. Проверка доступа к нодам

Перед запуском Kubespray:
```
ansible -i inventory/my-k8s-cluster/hosts.yml all -m ping -u lamer --become -b
```

Все ноды отвечают → SSH и sudo настроены правильно.

8. Запуск Kubespray

Финальная команда:
```
ansible-playbook \
  -i inventory/my-k8s-cluster/hosts.yml \
  cluster.yml \
  -u lamer \
  --become -b -v
```

После этого Kubespray начал выполнять реальные роли, а не падать на проверках.

9. Почему «поехало»

Потому что одновременно выполнены ВСЕ условия:

Компонент	Статус
Python	3.10.13 + ctypes
Ansible	2.17.x (строго по требованию)
Collections	Все нужные установлены
Inventory	Валидный YAML
SSH / sudo	Работают
Kubespray	Совместим с Ansible
 
Проверка
```
ansible -i inventory/my-k8s-cluster/hosts.yml all -m ping
```
![Рисунок 15](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_15.jpg) 
![Рисунок 16](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_16.jpg) 



## Теперь можно запускать запускать Kubespray.

Команда (ровно одна):
```
ansible-playbook -i inventory/my-k8s-cluster/hosts.yml cluster.yml -u lamer --become -b -v
```

**Если необходимо я готов выставить рабочую версии!**
 
Установка прошла успешно 
![Рисунок 17](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_17.jpg) 

подлючимся к мастер ноде и проверим состояние 

```
sudo -i
export KUBECONFIG=/etc/kubernetes/admin.conf
```
```
kubectl get nodes
kubectl get pods -n kube-system
```

все установилось, все в порядке 

![Рисунок 18](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_18.jpg) 
 
 
## настройка дотупа с локальной машины
 Скопируем файл admin.conf в домашний каталог
```
ssh -l lamer 93.77.181.183
sudo cp /etc/kubernetes/admin.conf /home/lamer/admin.conf
sudo chown lamer:lamer /home/lamer/admin.conf
chmod 600 /home/lamer/admin.conf
```


Теперь скачаем файл настройки кластера на свой компьютер
```
scp lamer@93.77.181.183:/home/lamer/admin.conf ~/k8s-admin.conf
```

   
Откроем файл и перепишем настройки server:
```
nano ~/k8s-admin.conf
```

В секции clusters добавить  insecure-skip-tls-verify: true и #certificate-authority-data нужно закоментировать

```
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://93.77.181.183:6443
```

экспортируем настройки в командную оболочку


```
export KUBECONFIG=~/k8s-admin.conf
kubectl get nodes -o wide
```

проверим работу кластера

```
kubectl get nodes
kubectl get pods --all-namespaces
```

![Рисунок 18](https://github.com/ysatii/devops-diplom-yandexcloud/blob/main/img/img_18.jpg) 
 
