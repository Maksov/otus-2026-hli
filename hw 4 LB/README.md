## Домашее задание № 4 Балансировка веб-приложения

### Занятие 10. Альтернативные балансировщики: envoy, traefik

#### Цель:
научиться развертыванию серверов веб-приложения, способного выдерживать высокие нагрузки и обеспечивать отказоустойчивость, используя Terraform (или Vagrant) и Ansible.
---

#### Описание/Пошаговая инструкция выполнения домашнего задания:

1. Подготовка окружения:

ОС Microsoft Windows 11 WSL 2.0 Ubuntu
Ansible 2.12.3
Terraform v1.14.5
Yandex Cloud CLI 0.185.0
Terraform Provider Yanedx v0.187.0

2. Написание манифестов Terraform (особенности)

Каждый тип инстанса вынесли в отдельный файл:
|- lb.tf
|- frontend.tf
|- backend.tf

Доступ к вм настраивается с помощью cloud-init.yml

Provisioner - Ansible по внешним ip ВМ.

В манифестах используется образ Ubuntu 24.04


3. Написание Ansible playbook (особенности)

Инвентаризационный файл формируется дианмически Terraform.
Созданы следующие роли:


4. Запуск и настройка инфраструктуры 

```
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
---
terraform init
terraform validate
terraform plan
terrafrom apply
```

5. Результат
На 80 порту слушается алгоритм Round-Robin На 81 порту - hash

Алгоритм RR
Проврека браузером
Видим что балансировщик работает
![Фронтэнд 1](fr-1.png)
---
![Фронтэнд 2](fr-2.png)

Идет обращение к бэкэнду с каждого фронта
![Фронтэнд 1 Обращение к бэкэнду](fr-1-link-back.png)
---
![Фронтэнд 2 Обращение к бэкэнду](fr-1-link-back.png)

Алгоритм Hash по параметру ip
![Фронтэнд 2](hash.png)

6. Чистим облако за собой

После выполнения всех работ прибиваю все ресурсы
```
terraform destroy
```







