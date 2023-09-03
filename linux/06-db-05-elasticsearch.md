# Домашнее задание к занятию 5. «Elasticsearch»

## Задача 1

В этом задании вы потренируетесь в:

- установке Elasticsearch,
- первоначальном конфигурировании Elasticsearch,
- запуске Elasticsearch в Docker.

Используя Docker-образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для Elasticsearch,
- соберите Docker-образ и сделайте `push` в ваш docker.io-репозиторий,
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины.

Требования к `elasticsearch.yml`:

- данные `path` должны сохраняться в `/var/lib`,
- имя ноды должно быть `netology_test`.

В ответе приведите:

- текст Dockerfile-манифеста,
- ссылку на образ в репозитории dockerhub,
- ответ `Elasticsearch` на запрос пути `/` в json-виде.

Подсказки:

- возможно, вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum,
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml,
- при некоторых проблемах вам поможет Docker-директива ulimit,
- Elasticsearch в логах обычно описывает проблему и пути её решения.

Далее мы будем работать с этим экземпляром Elasticsearch.

Ответ:

Были сложности с доступом к некоторым файлам Elasticsearch , запрещено из РФ.
Поэтому были скачены необходимые дистрибутивы Elasticsearch и Java 17, 
также на ARM не проставлялись корректно права на папку (какой то баг докера) , пришлось делать на amd64 версию и запускать все на intel

В итоге все получилось , ссылка на образ и Dockerfile

Dockerfile
```sh
FROM centos:7
COPY elasticsearch-8.2.0-linux-x86_64.tar.gz  /opt
COPY elasticsearch-8.2.0-linux-x86_64.tar.gz.sha512  /opt
COPY openjdk-17.0.2_linux-aarch64_bin.tar.gz /opt
COPY openjdk-17.0.2_linux-x64_bin.tar.gz /opt

RUN cd /opt && \
    groupadd elasticsearch && \
    useradd -c "elasticsearch" -g elasticsearch elasticsearch &&\
    yum update -y && yum -y install perl-Digest-SHA && \
    shasum -a 512 -c elasticsearch-8.2.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-8.2.0-linux-x86_64.tar.gz && \
    tar xvf openjdk-17.0.2_linux-x64_bin.tar.gz  && \
    rm elasticsearch-8.2.0-linux-x86_64.tar.gz elasticsearch-8.2.0-linux-x86_64.tar.gz.sha512 && \
    rm openjdk-17.0.2_linux-aarch64_bin.tar.gz && \
    rm openjdk-17.0.2_linux-x64_bin.tar.gz && \
    mkdir /var/lib/data && chmod -R 777 /var/lib/data && \
    yum clean all

RUN chown -R elasticsearch:elasticsearch /opt/elasticsearch-8.2.0/


# Настроить Environment, вариант с паролем так и не заработал, поэтому отключил проверку 
ENV ELASTIC_PASSWORD=changeme
ENV ES_PATH_CONF=/opt/elasticsearch-8.2.0/config/
ENV ES_JAVA_HOME=/opt/jdk-17.0.2/

WORKDIR /opt/elasticsearch-8.2.0/
# во второй версии добавил сюда chown чтобы были права
COPY --chown=elasticsearch:elasticsearch elasticsearch.yml config/

USER elasticsearch


ENTRYPOINT ["bin/elasticsearch"]
EXPOSE 9200 9300
```

Конфиг эластика elasticsearch.yml

```sh
network.host: 0.0.0.0
discovery.type: single-node
cluster.name: netology
node.name: netology_test
path.data: /var/lib/data
#path.logs: /var/lib/logs
xpack.ml.enabled: false
xpack.security.enabled: false
#xpack.security.transport.ssl.enabled: false
```

Сбилдил  и запушил командами:
```sh
docker build -t sadotnet/elasticsearch .
```

Запушил:
```sh
docker login -u "sadotnet" docker.io
docker push sadotnet/elasticsearch:latest
```

Ссылка на образ:
https://hub.docker.com/r/sadotnet/elasticsearch/tags


Поднял через pull
```sh
docker run --rm -d --name elastic -p 9200:9200 -p 9300:9300 sadotnet/elasticsearch
```

Сделал запрос к localhost:

```sh
root@server:~# curl http://127.0.0.1:9200/
{
  "name" : "netology_test",
  "cluster_name" : "netology",
  "cluster_uuid" : "uw1SEL01RFqaLtkEgxSjRw",
  "version" : {
    "number" : "8.2.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "b174af62e8dd9f4ac4d25875e9381ffe2b9282c5",
    "build_date" : "2022-04-20T10:35:10.180408517Z",
    "build_snapshot" : false,
    "lucene_version" : "9.1.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```


## Задача 2

В этом задании вы научитесь:

- создавать и удалять индексы,
- изучать состояние кластера,
- обосновывать причину деградации доступности данных.

Ознакомьтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `Elasticsearch` 3 индекса в соответствии с таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |


**Важно**

При проектировании кластера Elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.


Ответ:

Последовательно выполнил пост запросы такого вида:

```sh
$ curl -X PUT "localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}
'
```

Лог выполнения и ответы
```sh
root@server:/home/vagrant/files#  curl -X PUT "localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'
> {
>   "settings": {
>     "number_of_shards": 1,
>     "number_of_replicas": 0
>   }
> }
> '
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-1"
}
root@server:/home/vagrant/files# curl -X PUT "localhost:9200/ind-2?pretty" -H 'Content-Type: application/json' -d'
> {
>   "settings": {
>     "number_of_shards": 2,
>     "number_of_replicas": 1
>   }
> }
> '
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-2"
}
root@server:/home/vagrant/files# curl -X PUT "localhost:9200/ind-3?pretty" -H 'Content-Type: application/json' -d'
> {
>   "settings": {
>     "number_of_shards": 4,
>     "number_of_replicas": 2
>   }
> }
> '
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-3"
}
```


Получите список индексов и их статусов, используя API, и **приведите в ответе** на задание.

Ответ:
```sh
vagrant@server:~$  curl 'localhost:9200/_cat/indices?v'
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 k8yDGCSRQe-veozqm3wuSw   1   0          0            0       225b           225b
yellow open   ind-3 PWERnV3NQGGugjeVDARHVw   4   2          0            0       900b           900b
yellow open   ind-2 QzQ4x2xATy6G3vVLu_k66w   2   1          0            0       450b           450b
```



Получите состояние кластера `Elasticsearch`, используя API.

```sh
vagrant@server:~$ curl -X GET "localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "netology",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```

Как вы думаете, почему часть индексов и кластер находятся в состоянии yellow?

Ответ:
Потому что нет шардов еще 

Удалите все индексы.

Ответ:
```sh
curl -X DELETE "http://localhost:9200/_all"
```

## Задача 3

В этом задании вы научитесь:

- создавать бэкапы данных,
- восстанавливать индексы из бэкапов.

Создайте директорию `{путь до корневой директории с Elasticsearch в образе}/snapshots`.

Используя API, [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
эту директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `Elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `Elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:

- возможно, вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `Elasticsearch`.

---

Ответ:
Пришлось переделать образ так как действительно не хватало прав править elasticsearch.yml в образе который на docker.io

Создал директорию и поправил конфиг эластика

```sh
docker exec -it elastic mkdir /opt/elasticsearch-8.2.0/snapshots 
docker exec -it elastic bash -c 'echo "path.repo: /opt/elasticsearch-8.2.0/snapshots" >> /opt/elasticsearch-8.2.0/config/elasticsearch.yml'
docker restart elastic
```

Зарегал эту директорию как snapshot repository

```sh
curl -X PUT "localhost:9200/_snapshot/netology_backup?verify=false&pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/opt/elasticsearch-8.2.0/snapshots"
  }
}
'
```

Проверим что все ок:
```sh
root@server:/home/vagrant/files# curl -X GET localhost:9200/_snapshot/netology_backup?pretty
{
  "netology_backup" : {
    "type" : "fs",
    "settings" : {
      "location" : "/opt/elasticsearch-8.2.0/snapshots"
    }
  }
}
```

Создадим индекс test с 0 реплик и 1 шардом:
```sh
curl -X PUT localhost:9200/test -H 'Content-Type: application/json' -d '{"settings": {"index": {"number_of_shards": 1, "number_of_replicas": 0}}}{"acknowledged" : true, "shards_acknowledged" : true, "index" : "test"}'
```

```sh
curl -X GET localhost:9200/_cat/indices?v=true
```

```sh
root@server:/home/vagrant/files# curl -X GET localhost:9200/_cat/indices?v=true
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  qrPTdrqJQXqF_wSjJOE7xA   1   0          0            0       225b           225b
```

Создадим snapshot состояния кластера:

```sh
curl -X PUT "localhost:9200/_snapshot/netology_backup/%3Cmy_snapshot_%7Bnow%2Fd%7D%3E?pretty"
```
Вот такое имя должно получиться  my_snapshot_2023.09.03

```sh
docker exec -it elastic ls -laht /opt/elasticsearch-8.2.0/snapshots
```

Убедился что какие то файлы есть
```sh
root@server:/home/vagrant/files# docker exec -it elastic ls -laht /opt/elasticsearch-8.2.0/snapshots
total 72K
drwxr-xr-x 3 elasticsearch elasticsearch 4.0K Sep  3 11:00 .
-rw-r--r-- 1 elasticsearch elasticsearch    8 Sep  3 11:00 index.latest
-rw-r--r-- 1 elasticsearch elasticsearch 1.2K Sep  3 11:00 index-1
-rw-r--r-- 1 elasticsearch elasticsearch  17K Sep  3 11:00 meta-mqEMPsvAQ6WPWUC2nXJFIg.dat
-rw-r--r-- 1 elasticsearch elasticsearch  355 Sep  3 11:00 snap-mqEMPsvAQ6WPWUC2nXJFIg.dat
-rw-r--r-- 1 elasticsearch elasticsearch  17K Sep  3 10:56 meta-izjB-h_ETkikFBx7vjIaoA.dat
-rw-r--r-- 1 elasticsearch elasticsearch  365 Sep  3 10:56 snap-izjB-h_ETkikFBx7vjIaoA.dat
drwxr-xr-x 4 elasticsearch elasticsearch 4.0K Sep  3 10:56 indices
drwxr-xr-x 1 elasticsearch elasticsearch 4.0K Sep  3 10:39 ..
```

Удалил test и добавил test-2
```sh
curl -X DELETE localhost:9200/test
curl -X PUT localhost:9200/test-2 -H 'Content-Type: application/json' -d '{"settings": {"index": {"number_of_shards": 1, "number_of_replicas": 0}}}{"acknowledged" : true, "shards_acknowledged" : true, "index" : "test-2"}'
```

Проверил что test отстуствует
```sh
curl -X GET localhost:9200/_cat/indices?v=true
```

```sh
root@server:/home/vagrant/files# curl -X GET localhost:9200/_cat/indices?v=true
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 SPy6zEV8Q56qg6jgRG_eZQ   1   0          0            0       225b           225b
```

Восстановил из снапшота:
```sh
curl -X POST localhost:9200/_snapshot/netology_backup/my_snapshot_2023.09.03/_restore?pretty -H 'Content-Type: application/json' -d '{"indices": "*", "include_global_state": true}{"accepted" : true}'
```
Проверил что test появился и test-2 остался 

```sh
curl -X GET localhost:9200/_cat/indices?v=true
```

```sh
root@server:/home/vagrant/files# curl -X GET localhost:9200/_cat/indices?v=true
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 SPy6zEV8Q56qg6jgRG_eZQ   1   0          0            0       225b           225b
green  open   test   9KMjSN-STFiGoCbWHbnpDQ   1   0          0            0       225b           225b
```
