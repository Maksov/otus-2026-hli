## Домашее задание № 5 Развернуть InnoDB или PXC кластер

### Занятие 11. MySQL - кластер

#### Цель:
Перевести базу веб-проекта на один из вариантов кластера MySQL: Percona XtraDB Cluster или InnoDB Cluster.
---

#### Описание/Пошаговая инструкция выполнения домашнего задания:

1. Подготовка окружения:

ОС Microsoft Windows 11 WSL 2.0 Ubuntu
Ansible 2.12.3
Terraform v1.14.5
Yandex Cloud CLI 0.185.0
Terraform Provider Yandex v0.187.0

2. Написание манифестов Terraform (особенности)

Доступ к вм настраивается с помощью cloud-init.yml

Provisioner - Ansible по внешним ip ВМ.

В манифестах используется образ Ubuntu 24.04

Особенности конфигураций Angie:
- конфигурационные файлы сервер по пути /etc/angie/http.d/
- конфигурационные файлы upstream по пути /etc/angie/stream.d/
- Директория сайта апо умолчанию /usr/share/angie/html

3. Написание Ansible playbook (особенности)

Инвентаризационный файл формируется дианмически Terraform.
Использованы и настроены следующие роли:
- mysql //установка и настройка Percona XtraDB Cluster

Структура роли
```
|-defaults/  
|--main.yml   //Задание значений переменных
|-files/
|--ssl/       //Сертификаты
|---ca.pem
|---server-cert.pem
|---server-key.pem
|-handlers/
|--main.yml   //Хэндлеры. Рестарт сервисов
|-tasks/
|--bootstrap_cluster.yml   //Настройка кластера. Bootstrap
|--check-settings.yml
|--configure.yml          //Конфигурация кластера. Копирование параметризированных шаблонов на сервера кластера. Копирование ssl сертификатов
|--databases.yml          //Конфигурация БД
|--install.yml            //Инсталляция Percona XtraDB Cluster 8.0
|--main.yml                //Основноый плейбук роли
|--secure.yml               
|--users.yml
|-templates/             //Шаблоны конфигурационных файлов
|--etc_mysql_my.cnf.j2
|--etc_mysql_mysqld.cnf.j2
|--root-my-cnf.j2
```

Формрование сертификатов
ВАЖНО!!! CN CA сертификата и серверного не должны совпадать!

The Certificate Authority is used to verify the signature on certificates. These commands generate a Certificate Authority (CA) key and certificate:

Generate the CA key file:
```
openssl genrsa 2048 > ca-key.pem
```
The command generates a 2048-bit RSA private key and saves the key to ca-key.pem. This key is essential for signing certificates.

Generate the CA certificate file:

```
openssl req -new -x509 -nodes -days 3600
    -key ca-key.pem -out ca.pem
```
The command does the following:

Generates a self-signed CA certificate valid for 3600 days.

Uses the previously created private key (ca-key.pem).

Ensures the private key is not encrypted with the -nodes flag.

Outputs the certificate to ca.pem.

This CA certificate can then be used to sign other certificates for secure authentication within a system.

Generate a new RSA key pair and certificate request:

```
openssl req -newkey rsa:2048 -days 3600 \
    -nodes -keyout server-key.pem -out server-req.pem
The command does the following:
```

Creates a 2048-bit RSA private key (server-key.pem).

Generates a certificate signing request (CSR) (server-req.pem).

-days 3600 sets the certificate validity period to 3600 days.

-nodes ensures the private key remains unencrypted.

This command reads an RSA private key from the server-key.pem file, processes the key, and then writes the processed key back to the same file, removing the passphrase.

```
openssl rsa -in server-key.pem -out server-key.pem
```

This command generates a signed certificate from a CSR using a specified CA certificate and its corresponding private key. The command also sets a defined validity period and serial number for the new certificate.

```
openssl x509 -req -in server-req.pem -days 3600 \
    -CA ca.pem -CAkey ca-key.pem -set_serial 01 \
    -out server-cert.pem
```
The command does the following:

Processes a certificate signing request (CSR) from the server-req.pem file.

Sets the generated certificate’s validity period to 3600 days, using the -days 3600 option.

Specifies the Certificate Authority (CA) certificate, ca.pem, to sign the CSR with the -CA ca.pem option.

Provides the CA certificate’s private key, ca-key.pem, for signing the CSR using the -CAkey ca-key.pem option.

Assigns a serial number of 01 to the newly created certificate using the -set_serial 01 option.

Writes the resulting signed certificate to the server-cert.pem file, using the -out server-cert.pem option.


Verify certificates¶
To check whether the server and client certificates are properly signed by the Certificate Authority (CA) certificate, run the following command:
```
openssl verify -CAfile ca.pem server-cert.pem
```
This command verifies that the server and client certificates are valid and trusted by the specified CA certificate (ca.pem). If the certificates are correctly signed, OpenSSL returns a confirmation message;
otherwise, error details indicate issues with the certificate chain.
```
server-cert.pem: OK
```

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

```
mysql> show status like 'wsrep%';
+----------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+
| Variable_name                    | Value                                                                                                                                          |
+----------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+
| wsrep_local_state_uuid           | 2100bd98-2d5b-11f1-86d6-c6e24ec521b0                                                                                                           |
| wsrep_protocol_version           | 11                                                                                                                                             |
| wsrep_last_applied               | 6                                                                                                                                              |
| wsrep_protocol_application       | 4                                                                                                                                              |
| wsrep_protocol_replicator        | 11                                                                                                                                             |
| wsrep_protocol_GCS               | 5                                                                                                                                              |
| wsrep_last_committed             | 6                                                                                                                                              |
| wsrep_monitor_status (L/A/C)     | [ (7, 7), (6, 6), (6, 6) ]                                                                                                                     |
| wsrep_replicated                 | 0                                                                                                                                              |
| wsrep_replicated_bytes           | 0                                                                                                                                              |
| wsrep_repl_keys                  | 0                                                                                                                                              |
| wsrep_repl_keys_bytes            | 0                                                                                                                                              |
| wsrep_repl_data_bytes            | 0                                                                                                                                              |
| wsrep_repl_other_bytes           | 0                                                                                                                                              |
| wsrep_received                   | 6                                                                                                                                              |
| wsrep_received_bytes             | 992                                                                                                                                            |
| wsrep_local_commits              | 0                                                                                                                                              |
| wsrep_local_cert_failures        | 0                                                                                                                                              |
| wsrep_local_replays              | 0                                                                                                                                              |
| wsrep_local_send_queue           | 0                                                                                                                                              |
| wsrep_local_send_queue_max       | 1                                                                                                                                              |
| wsrep_local_send_queue_min       | 0                                                                                                                                              |
| wsrep_local_send_queue_avg       | 0                                                                                                                                              |
| wsrep_local_recv_queue           | 0                                                                                                                                              |
| wsrep_local_recv_queue_max       | 1                                                                                                                                              |
| wsrep_local_recv_queue_min       | 0                                                                                                                                              |
| wsrep_local_recv_queue_avg       | 0                                                                                                                                              |
| wsrep_local_cached_downto        | 3                                                                                                                                              |
| wsrep_flow_control_paused_ns     | 0                                                                                                                                              |
| wsrep_flow_control_paused        | 0                                                                                                                                              |
| wsrep_flow_control_sent          | 0                                                                                                                                              |
| wsrep_flow_control_recv          | 0                                                                                                                                              |
| wsrep_flow_control_active        | false                                                                                                                                          |
| wsrep_flow_control_requested     | false                                                                                                                                          |
| wsrep_flow_control_interval      | [ 173, 173 ]                                                                                                                                   |
| wsrep_flow_control_interval_low  | 173                                                                                                                                            |
| wsrep_flow_control_interval_high | 173                                                                                                                                            |
| wsrep_flow_control_status        | OFF                                                                                                                                            |
| wsrep_cert_deps_distance         | 0                                                                                                                                              |
| wsrep_apply_oooe                 | 0                                                                                                                                              |
| wsrep_apply_oool                 | 0                                                                                                                                              |
| wsrep_apply_window               | 0                                                                                                                                              |
| wsrep_apply_waits                | 0                                                                                                                                              |
| wsrep_commit_oooe                | 0                                                                                                                                              |
| wsrep_commit_oool                | 0                                                                                                                                              |
| wsrep_commit_window              | 0                                                                                                                                              |
| wsrep_local_state                | 4                                                                                                                                              |
| wsrep_local_state_comment        | Synced                                                                                                                                         |
| wsrep_cert_index_size            | 0                                                                                                                                              |
| wsrep_cert_bucket_count          | 1                                                                                                                                              |
| wsrep_gcache_pool_size           | 5360                                                                                                                                           |
| wsrep_causal_reads               | 0                                                                                                                                              |
| wsrep_cert_interval              | 0                                                                                                                                              |
| wsrep_open_transactions          | 0                                                                                                                                              |
| wsrep_open_connections           | 0                                                                                                                                              |
| wsrep_ist_receive_status         |                                                                                                                                                |
| wsrep_ist_receive_seqno_start    | 0                                                                                                                                              |
| wsrep_ist_receive_seqno_current  | 0                                                                                                                                              |
| wsrep_ist_receive_seqno_end      | 0                                                                                                                                              |
| wsrep_incoming_addresses         | 10.160.0.101:3306,10.160.0.102:3306,10.160.0.100:3306                                                                                          |
| wsrep_cluster_weight             | 3                                                                                                                                              |
| wsrep_desync_count               | 0                                                                                                                                              |
| wsrep_evs_delayed                |                                                                                                                                                |
| wsrep_evs_evict_list             |                                                                                                                                                |
| wsrep_evs_repl_latency           | 0/0/0/0/0                                                                                                                                      |
| wsrep_evs_state                  | OPERATIONAL                                                                                                                                    |
| wsrep_gcomm_uuid                 | 8dda1000-2d5b-11f1-857f-aa9f1449f690                                                                                                           |
| wsrep_gmcast_segment             | 0                                                                                                                                              |
| wsrep_cluster_capabilities       |                                                                                                                                                |
| wsrep_cluster_conf_id            | 5                                                                                                                                              |
| wsrep_cluster_size               | 3                                                                                                                                              |
| wsrep_cluster_state_uuid         | 2100bd98-2d5b-11f1-86d6-c6e24ec521b0                                                                                                           |
| wsrep_cluster_status             | Primary                                                                                                                                        |
| wsrep_connected                  | ON                                                                                                                                             |
| wsrep_local_bf_aborts            | 0                                                                                                                                              |
| wsrep_local_index                | 0                                                                                                                                              |
| wsrep_provider_capabilities      | :MULTI_MASTER:CERTIFICATION:PARALLEL_APPLYING:TRX_REPLAY:ISOLATION:PAUSE:CAUSAL_READS:INCREMENTAL_WRITESET:UNORDERED:PREORDERED:STREAMING:NBO: |
| wsrep_provider_name              | Galera                                                                                                                                         |
| wsrep_provider_vendor            | Codership Oy <info@codership.com> (modified by Percona <https://percona.com/>)                                                                 |
| wsrep_provider_version           | 4.24(c71acc5)                                                                                                                                  |
| wsrep_ready                      | ON                                                                                                                                             |
| wsrep_thread_count               | 9                                                                                                                                              |
+----------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+
82 rows in set (0.03 sec)
```

Импортируем preset sakila-db
```
admind@pxc-1:~/sakila-db# wget https://downloads.mysql.com/docs/sakila-db.tar.gz
admind@pxc-1:~/sakila-db# mysql
mysql> source sakila-schema.sql;
mysql> source sakila-data.sql;
```

Проверяем на соседней ноде кластера
```
admind@pxc-2:~# mysql
mysql> use sakila;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;\
+----------------------------+
| Tables_in_sakila           |
+----------------------------+
| actor                      |
| actor_info                 |
| address                    |
| category                   |
| city                       |
| country                    |
| customer                   |
| customer_list              |
| film                       |
| film_actor                 |
| film_category              |
| film_list                  |
| film_text                  |
| inventory                  |
| language                   |
| nicer_but_slower_film_list |
| payment                    |
| rental                     |
| sales_by_film_category     |
| sales_by_store             |
| staff                      |
| staff_list                 |
| store                      |
+----------------------------+
23 rows in set (0.01 sec)
```

6. Чистим облако за собой

После выполнения всех работ прибиваю все ресурсы
```
terraform destroy
```







