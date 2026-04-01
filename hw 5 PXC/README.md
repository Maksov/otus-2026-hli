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

6. Чистим облако за собой

После выполнения всех работ прибиваю все ресурсы
```
terraform destroy
```







