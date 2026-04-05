## Домашее задание № 6 Кластер PostgreSQL с Patroni

### Занятие 12. PostgreSQL cluster

#### Цель:
развернуть отказоустойчивый кластер PostgreSQL;
обеспечить автоматическое управление лидерством и высокую доступность с помощью Patroni;
настроить сервис-дискавери через etcd/Consul/ZooKeeper и балансировку с HAProxy или PgBouncer.
---

#### Описание/Пошаговая инструкция выполнения домашнего задания:

1. Подготовка окружения:

ОС Microsoft Windows 11 WSL 2.0 Ubuntu
Ansible 2.12.3
Terraform v1.14.5
Yandex Cloud CLI 1.0.0
Terraform Provider Yandex v0.187.0

2. Написание манифестов Terraform (особенности)

Доступ к вм настраивается с помощью cloud-init.yml

Provisioner - Ansible по внешним ip ВМ.

В манифестах используется образ Ubuntu 24.04

3. Написание Ansible playbook (особенности)

Инвентаризационный файл формируется дианмически Terraform.
Использованы и настроены следующие роли:
- watchdog //настройка программного сторожевого таймера softdog
- etcd //установка и настройка Etcd (сервиса DCS, для хранения конфигурации Patroni)
- pg_cluster //установка и настройка Percona Distribution for PostgreSQL (если кратко,ставим и настраиваем кластер PostgreSQL с Patroni)
- haproxy //установка и настройка балансировщика нагрузки HAProxy

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

### ETCD
```
admind@pg-1:~$ sudo etcdctl member list --write-out=table
+------------------+---------+------+--------------------------+--------------------------+------------+
|        ID        | STATUS  | NAME |        PEER ADDRS        |       CLIENT ADDRS       | IS LEARNER |
+------------------+---------+------+--------------------------+--------------------------+------------+
| 9513514a508c69b4 | started | pg-2 | http://10.160.0.101:2380 | http://10.160.0.101:2379 |      false |
| efc8b30be6c1b430 | started | pg-3 | http://10.160.0.102:2380 | http://10.160.0.102:2379 |      false |
| ffb0f5f139f83d38 | started | pg-1 | http://10.160.0.100:2380 | http://10.160.0.100:2379 |      false |
+------------------+---------+------+--------------------------+--------------------------+------------+
```
### Patroni

```
admind@pg-1:~$ sudo patronictl -c /etc/patroni/patroni.yml list
+ Cluster: pg_cluster (7625400705623386299) -------------+-----+------------+-----+
| Member | Host | Role    | State     | TL | Receive LSN | Lag | Replay LSN | Lag |
+--------+------+---------+-----------+----+-------------+-----+------------+-----+
| pg-1   | pg-1 | Replica | streaming |  1 |   0/404F770 |   0 |  0/404F770 |   0 |
| pg-2   | pg-2 | Replica | streaming |  1 |   0/404F770 |   0 |  0/404F770 |   0 |
| pg-3   | pg-3 | Leader  | running   |  1 |             |     |            |     |
+--------+------+---------+-----------+----+-------------+-----+------------+-----+
```

### Импорт БД

Переходим на лидера pg-3
```
admind@pg-3:~$ wget https://edu.postgrespro.ru/demo-medium-20161013.zip
admind@pg-3:~$ unzip demo-medium-20161013.zip
admind@pg-3:~$ psql -U postgres
psql (17.9 - Percona Server for PostgreSQL 17.9.1 - Percona Distribution)
Type "help" for help.
postgres=# create database demo;
CREATE DATABASE
postgres=# \q

admind@pg-3:~$ psql -U postgres demo < demo_medium.sql
admind@pg-3:~$ psql -U postgres
psql (17.9 - Percona Server for PostgreSQL 17.9.1 - Percona Distribution)
Type "help" for help.

postgres=# \l+
                                                                                   List of databases
   Name    |  Owner   | Encoding | Locale Provider | Collate |  Ctype  | Locale | ICU Rules |   Access privileges   |  Size   | Tablespace |                Description
-----------+----------+----------+-----------------+---------+---------+--------+-----------+-----------------------+---------+------------+--------------------------------------------
 demo      | postgres | UTF8     | libc            | C.UTF-8 | C.UTF-8 |        |           |                       | 704 MB  | pg_default |
 postgres  | postgres | UTF8     | libc            | C.UTF-8 | C.UTF-8 |        |           |                       | 7502 kB | pg_default | default administrative connection database
 template0 | postgres | UTF8     | libc            | C.UTF-8 | C.UTF-8 |        |           | =c/postgres          +| 7345 kB | pg_default | unmodifiable empty database
           |          |          |                 |         |         |        |           | postgres=CTc/postgres |         |            |
 template1 | postgres | UTF8     | libc            | C.UTF-8 | C.UTF-8 |        |           | =c/postgres          +| 7574 kB | pg_default | default template for new databases
           |          |          |                 |         |         |        |           | postgres=CTc/postgres |         |            |
(4 rows)
```
Проверяем на первой (pg-1) или второй (pg-2) ноде
```
admind@pg-1:~$ psql -U postgres
psql (17.9 - Percona Server for PostgreSQL 17.9.1 - Percona Distribution)
Type "help" for help.

postgres=# \l+
                                                                                   List of databases
   Name    |  Owner   | Encoding | Locale Provider | Collate |  Ctype  | Locale | ICU Rules |   Access privileges   |  Size   | Tablespace |                Description
-----------+----------+----------+-----------------+---------+---------+--------+-----------+-----------------------+---------+------------+--------------------------------------------
 demo      | postgres | UTF8     | libc            | C.UTF-8 | C.UTF-8 |        |           |                       | 702 MB  | pg_default |
 postgres  | postgres | UTF8     | libc            | C.UTF-8 | C.UTF-8 |        |           |                       | 7502 kB | pg_default | default administrative connection database
 template0 | postgres | UTF8     | libc            | C.UTF-8 | C.UTF-8 |        |           | =c/postgres          +| 7345 kB | pg_default | unmodifiable empty database
           |          |          |                 |         |         |        |           | postgres=CTc/postgres |         |            |
 template1 | postgres | UTF8     | libc            | C.UTF-8 | C.UTF-8 |        |           | =c/postgres          +| 7417 kB | pg_default | default template for new databases
           |          |          |                 |         |         |        |           | postgres=CTc/postgres |         |            |
(4 rows)
```

###HAProxy
Для того чтобы HAproxy узнал, какова роль каждого узла в данный момент, он посылает HTTP-запрос на порт 8008 узла: Patroni ответит на него. Patroni предоставляет встроенную поддержку REST API для мониторинга проверки работоспособности, которая идеально интегрируется для этого с HAproxy

```
admind@haproxy:~$ curl http://pg-3:8008
{"state": "running", "postmaster_start_time": "2026-04-05 22:09:16.084243+00:00", "role": "primary", "server_version": 170009, "xlog": {"location": 1042386624}, "timeline": 1, "replication": [{"usename": "replicator", "application_name": "pg-1", "client_addr": "10.160.0.100", "state": "streaming", "sync_state": "async", "sync_priority": 0}, {"usename": "replicator", "application_name": "pg-2", "client_addr": "10.160.0.101", "state": "streaming", "sync_state": "async", "sync_priority": 0}], "dcs_last_seen": 1775428027, "database_system_identifier": "7625400705623386299", "patroni": {"version": "4.1.0", "scope": "pg_cluster", "name": "pg-3"}}
```

Проверяем коннект к Postgres
Список БД не показывает (ошибка), список таблиц БД demo также отсутсвует. Почему - не разобрался. Возможно из-за версионности клиента и сервера

```
admind@haproxy:~$ psql -U postgres -h 10.160.0.24 -p 5000
Password for user postgres:
psql (16.13 (Ubuntu 16.13-0ubuntu0.24.04.1), server 17.9 - Percona Server for PostgreSQL 17.9.1 - Percona Distribution)
WARNING: psql major version 16, server major version 17.
         Some psql features might not work.
Type "help" for help.

postgres=# \l+
ERROR:  column d.daticulocale does not exist
LINE 8:   d.daticulocale as "ICU Locale",
          ^
HINT:  Perhaps you meant to reference the column "d.datlocale".
postgres=# \c demo
demo=# \dt
Did not find any relations.
```

6. Чистим облако за собой

После выполнения всех работ прибиваю все ресурсы
```
terraform destroy
```







