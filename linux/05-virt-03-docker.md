
# Домашнее задание к занятию 3. «Введение. Экосистема. Архитектура. Жизненный цикл Docker-контейнера»
---

## Задача 1

Сценарий выполнения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберите любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```

Опубликуйте созданный fork в своём репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

**Ответ**
Линк для справки:
https://www.dmosk.ru/miniinstruktions.php?mini=docker-self-image

Выбрал образ nginx:1.22.1 , собрал в docker установленном в ВМ (vagrant).
Скрипт:
```sh
mkdir mynginx
cd mynginx/
sudo tee index.html<<EOF
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
EOF
sudo tee Dockerfile<<EOF
FROM nginx:1.22.1
RUN apt-get update && apt-get upgrade -y
COPY index.html /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
EOF
docker build -t mynginx:1.22.1 .
# проверка что создан
docker image ls
docker run -d --name mynginx-container -p 8080:80 mynginx:1.22.1
# проверка что контейнер с моего кастомного образа поднялся
docker ps
# проверка что работает сайт внутри моего docker контейнера
curl http://127.0.0.1:8080
# push to Docker hub
docker login
#docker tag <image name>:<tag> <dockerhub username>/<image name>:<tag>
docker tag mynginx:1.22.1 sadotnet/mynginx:1.22.1
#docker push <image name:tag>
docker push sadotnet/mynginx:1.22.1
```

Проверил на другой виртуалке, всё окей:
```sh
sudo docker pull sadotnet/mynginx:1.22.1
sudo docker image ls

sudo docker run -d -p 8080:80 sadotnet/mynginx:1.22.1
curl http://127.0.0.1:8080

<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```

**Итого:**
https://hub.docker.com/r/sadotnet/mynginx


## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
«Подходит ли в этом сценарии использование Docker-контейнеров или лучше подойдёт виртуальная машина, физическая машина? Может быть, возможны разные варианты?»

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- высоконагруженное монолитное Java веб-приложение;
- Nodejs веб-приложение;
- мобильное приложение c версиями для Android и iOS;
- шина данных на базе Apache Kafka;
- Elasticsearch-кластер для реализации логирования продуктивного веб-приложения — три ноды elasticsearch, два logstash и две ноды kibana;
- мониторинг-стек на базе Prometheus и Grafana;
- MongoDB как основное хранилище данных для Java-приложения;
- Gitlab-сервер для реализации CI/CD-процессов и приватный (закрытый) Docker Registry.

**Ответ:**
*высоконагруженное монолитное Java веб-приложение;*
Можно и в докере запустить, но так как высонагруженный монолит, то лучше запустить на физической машине с доступом к ресурсам машины напрямую.

*Nodejs веб-приложение;*
Вполне сгодится докер для запуска небольших легковесных nodejs приложений

*мобильное приложение c версиями для Android и iOS;*
Скорее всего запуск будет в эмуляторе осуществляться, с использованием тех инструментов который предоставляет разработчик среды разработки.

*шина данных на базе Apache Kafka;*
Есть мнение, что лучше ставить кластер kafka на голом железе, но есть опыт и запуска в докер, правда нормальных докер образов для этого не существует.

*Elasticsearch-кластер для реализации логирования продуктивного веб-приложения — три ноды elasticsearch, два logstash и две ноды kibana;*
Запускают и так и так, скорее всего будет зависеть от наличия физических или виртуальных машин.

*мониторинг-стек на базе Prometheus и Grafana;*
Можно запустить в докере, что часто и делается.

*MongoDB как основное хранилище данных для Java-приложения;*
Любые СУБД не очень приветствуется запуск в докере, но напрямую никто не запрещает (если это не только кубернетс), поэтому я бы запускал на ВМ.

*Gitlab-сервер для реализации CI/CD-процессов и приватный (закрытый) Docker Registry.*
Можно запустить в докере, можно в виртуалке, но смысла например выделять физическую машину под него точно нет.

## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тегом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера.
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера.
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```.
- Добавьте ещё один файл в папку ```/data``` на хостовой машине.
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

**Ответ:**

```sh
mkdir data
sudo docker run -it --rm -d --name centos -v $(pwd)/data:/data centos:latest
sudo docker run -it --rm -d --name debian -v $(pwd)/data:/data debian:latest

#on centos
docker exec -it centos bash
echo "hello from centos" > /data/hello
exit

#on host
echo "hello from host" > data/hello2

#on debian
docker exec -it debian bash
root@532ec0eaa499:/# ls -laht /data/
total 16K
-rw-rw-r-- 1 1000 1000   16 Mar 25 21:37 hello2
drwxrwxr-x 2 1000 1000 4.0K Mar 25 21:36 .
-rw-r--r-- 1 root root   18 Mar 25 21:35 hello
drwxr-xr-x 1 root root 4.0K Mar 25 21:26 ..
```


## Задача 4 (*)

Воспроизведите практическую часть лекции самостоятельно.
Соберите Docker-образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.


**Ответ:**

Неудачно попробовал такой Dockerfile
```sh
FROM alpine:3.14
RUN  CARGO_NET_GIT_FETCH_WITH_CLI=1 && \
     apk --no-cache add \
sudo python3 py3-pip openssl ca-certificates sshpass openssh-client rsync git && \
     apk --no-cache add \
     --virtual build-dependencies python3-dev libffi-dev musl-dev gcc cargo openssl-dev \
        libressl-dev \
        build-base && \
     pip install --upgrade pip wheel && \
     pip install --upgrade cryptography cffi && \
     pip install ansible==2.9.24 && \
     pip install mitogen ansible-lint jmespath && \
     pip install --upgrade pywinrm && \
     apk del build-dependencies && \
     rm -rf /var/cache/apk/* && \
     rm -rf /root/.cache/pip && \
     rm -rf /root/.cargo

RUN  mkdir /ansible && \
     mkdir -p /etc/ansible && \
     echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible
COPY ansible.cfg /ansible/

CMD  [ "ansible-playbook", "--version" ]
```

Вот так:
```sh
mkdir myansible
cd myansible
# создал свой ansible.cfg
# запуск сборки
docker build -t myansible:2.9.24 .
# получил ошибку 
#0 246.0   Attempting uninstall: packaging
#0 246.0     Found existing installation: packaging 20.9
#0 246.0 ERROR: Cannot uninstall 'packaging'. It is a distutils installed project and thus we cannot accurately determine which files belong to it which would lead to only a partial uninstall.
```

Поэтому собрал свой образ ansible на базе alpine, вот таким образом:
```sh
FROM alpine:3.14
RUN  apk add --no-cache ansible
RUN  mkdir /ansible && \
     mkdir -p /etc/ansible && \
     echo 'localhost' > /etc/ansible/hosts
WORKDIR /ansible
COPY ansible.cfg /ansible/
CMD  [ "ansible-playbook", "--version" ]
```

Проверил,  ansible-playbook отработал как надо:
```sh
root@server1:~/myansible# docker run --name test myansible:2.9.24
ansible-playbook 2.10.5
  config file = /ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.9/site-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 3.9.16 (main, Dec 10 2022, 13:47:19) [GCC 10.3.1 20210424]
```sh

**Результат запушил:**
```sh
docker tag myansible:2.9.24 sadotnet/myansible:2.9.24
docker push sadotnet/myansible:2.9.24
```

**Итого:**

`https://hub.docker.com/r/sadotnet/myansible`

