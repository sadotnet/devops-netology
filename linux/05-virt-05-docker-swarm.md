# Домашнее задание к занятию 5. «Оркестрация кластером Docker контейнеров на примере Docker Swarm»

---

## Задача 1


- В чём отличие режимов работы сервисов в Docker Swarm-кластере: replication и global?

Ответ:
В Docker Swarm кластере есть два режима работы сервисов - "replication" (репликация) и "global" (глобальный).
1. Режим "replication" позволяет запустить несколько реплик (инстансов) сервиса на разных узлах кластера. Количество реплик определяется пользователем и каждая реплика выполняется на отдельном узле. Это полезно для обеспечения высокой доступности и масштабируемости приложений. Если одна из реплик выходит из строя, Swarm автоматически создает новую, чтобы поддерживать указанное количество реплик.
2. Режим "global" гарантирует запуск по одной инстанции сервиса на каждом доступном узле в кластере. То есть, каждый узел будет иметь только одну копию сервиса, независимо от количества узлов в кластере. Этот режим полезен для приложений, которые требуют запуска на каждом узле кластера, например, мониторинг или сбор логов.
Выбор между режимами "replication" и "global" зависит от наших требований к отказоустойчивости и масштабируемости


- Какой алгоритм выбора лидера используется в Docker Swarm-кластере?
В Docker Swarm кластере, используется алгоритм выбора лидера, известный как Raft. Алгоритм Raft обеспечивает консенсус среди узлов в кластере для выбора лидера, который будет координировать и управлять состоянием кластера. Этот алгоритм обеспечивает отказоустойчивость и надежность кластера Docker Swarm.


- Что такое Overlay Network?
Ответ:

В Docker Swarm, overlay network - это виртуальная сеть, построенная поверх сети хостов, которая позволяет контейнерам, работающим на разных узлах Swarm, общаться друг с другом. Overlay network предоставляет абстракцию для контейнеров, скрывая детали физической сетевой инфраструктуры.

Overlay network обеспечивает изолированную сеть для контейнеров, подобно тому, как хосты имеют свои собственные локальные сети. Она предоставляет механизмы маршрутизации и DNS-резолвинга (resolving), чтобы контейнеры могли находить друг друга на основе их имен или сетевых идентификаторов. Благодаря overlay network, приложения, развернутые в Docker Swarm, могут без проблем общаться и взаимодействовать по сети, независимо от того, на каком узле они запущены.

Использование overlay network в Docker Swarm позволяет упростить конфигурацию и масштабирование сетей для приложений, управляемых Swarm-кластером, и обеспечивает гибкость и мобильность контейнеров.


## Задача 2

Создайте ваш первый Docker Swarm-кластер в Яндекс Облаке.
Чтобы получить зачёт, предоставьте скриншот из терминала (консоли) с выводом команды:
```
docker node ls
```

Ответ:
Для решения всех задач в задании (включая развертывания кластера мониторинга) я использовал yandex cloud, terraform скрипты (из задания) и  ansible playbook 
swarm-deploy-cluster.yml
swarm-deploy-sync.yml
swarm-deploy-stack.yml

Использовал inventory который сгенерировал для меня terraform после поднятия 6 ВМ с centos в yandex cloud.
Все плейбуки и роли посмотрел , разобрался в них. 


```sh
[root@node01 ~]# docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
6pdi4izz5idjwl43ofojxxosi *   node01.netology.yc   Ready     Active         Leader           24.0.5
qqq2s9v7bx5db32d1j0920s77     node02.netology.yc   Ready     Active         Reachable        24.0.5
lkd00gcdb3gp6qrw7gfnljk1x     node03.netology.yc   Ready     Active         Reachable        24.0.5
yj39co4ngf810s3ogy33otagy     node04.netology.yc   Ready     Active                          24.0.5
016n2zun1aefvplyq9ws3vvfd     node05.netology.yc   Ready     Active                          24.0.5
616gkiaujxh6dqpesegeyvte4     node06.netology.yc   Ready     Active                          24.0.5
```


## Задача 3

Создайте ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

Чтобы получить зачёт, предоставьте скриншот из терминала (консоли), с выводом команды:
```
docker service ls
```
Ответ:

```sh
[root@node01 ~]# docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
a3c5o89x0ark   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0
lr62bkq7uh7h   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
i0chjtdsz2bw   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest
vnlypa28xa43   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest
fifvho29av5b   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4
1nht4tql2dea   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0
0uosbe0kwhw0   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0
i52hk8w1yalb   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0
```


## Задача 4 (*)

Выполните на лидере Docker Swarm-кластера команду, указанную ниже, и дайте письменное описание её функционала — что она делает и зачем нужна:
```
# см.документацию: https://docs.docker.com/engine/swarm/swarm_manager_locking/
docker swarm update --autolock=true
```

Ответ:
```sh
[root@node01 ~]# docker swarm update --autolock=true
Swarm updated.
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-z9oAfp8Y3GQm/HPoOJ727eQiAFOx5d6oFhB6KT8oub8

Please remember to store this key in a password manager, since without it you
will not be able to restart the manager.
```
Комментарий:
Команда "docker swarm update --autolock=true" используется для обновления параметра --autolock на true в Docker Swarm. 
Параметр --autolock гарантирует, что после каждого перезагрузки или остановки менеджера кластера, мы должны вручную разблокировать кластер
Включение автоматической блокировки при помощи значения true полезно для повышения уровня безопасности, но на мой взгляд это не очень удобно в использовании ))) 
