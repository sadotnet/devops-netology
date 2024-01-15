# Домашнее задание к занятию 5 «Тестирование roles»

## Подготовка к выполнению

1. Установите molecule и его драйвера: `pip3 install "molecule molecule_docker molecule_podman`.
2. Выполните `docker pull aragast/netology:latest` —  это образ с podman, tox и несколькими пайтонами (3.7 и 3.9) внутри.

## Основная часть

Ваша цель — настроить тестирование ваших ролей. 

Задача — сделать сценарии тестирования для vector. 

Ожидаемый результат — все сценарии успешно проходят тестирование ролей.

### Molecule

1. Запустите  `molecule test -s ubuntu_xenial` (или с любым другим сценарием, не имеет значения) внутри корневой директории clickhouse-role, посмотрите на вывод команды. Данная команда может отработать с ошибками или не отработать вовсе, это нормально. Наша цель - посмотреть как другие в реальном мире используют молекулу И из чего может состоять сценарий тестирования.

Ответ: 
у меня он не отработал без ошибок

2. Перейдите в каталог с ролью vector-role и создайте сценарий тестирования по умолчанию при помощи `molecule init scenario --driver-name docker`.

Ответ:
готово

3. Добавьте несколько разных дистрибутивов (oraclelinux:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.
Ответ:
готово

4. Добавьте несколько assert в verify.yml-файл для  проверки работоспособности vector-role (проверка, что конфиг валидный, проверка успешности запуска и др.). 

Ответ:
добавлен verify.yml

5. Запустите тестирование роли повторно и проверьте, что оно прошло успешно.
Ответ:
готово

5. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.
Ответ:
готово

### Tox

1. Добавьте в директорию с vector-role файлы из [директории](./example).
Ответ:
скачал

2. Запустите `docker run --privileged=True -v <path_to_repo>:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/
bash`, где path_to_repo — путь до корня репозитория с vector-role на вашей файловой системе.

Ответ: для macbook m-чипа вышло предупреждение
docker run --privileged=True -v /Users/ventura/netology/my_roles_for_mht04/vector-role:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash

WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested

Ответ и сам tox не работал пока не доставил ansible , подробности ниже


3. Внутри контейнера выполните команду `tox`, посмотрите на вывод.

Ответ:
При запуске команды tox
[root@2c8c28a91bbc vector-role]# tox
py37-ansible210 create: /opt/vector-role/.tox/py37-ansible210
py37-ansible210 installdeps: -rtox-requirements.txt, ansible<3.0
зависло вот над этом

5. Создайте облегчённый сценарий для `molecule` с драйвером `molecule_podman`. Проверьте его на исполнимость.
Ответ:
чтобы заработало пришлось еще поставить ansible и добавил сценарий light_scenario, проверил чтобы заработало 

```sh
pip install ansible
Collecting ansible

  Downloading ansible-4.10.0.tar.gz (36.8 MB)
     |████████████████████████████████| 36.8 MB 837 kB/s            

```

6. Пропишите правильную команду в `tox.ini`, чтобы запускался облегчённый сценарий.

Поправил tox.ini

```sh

[testenv]
deps =
    molecule
    molecule-podman
commands =
    molecule test -s light_scenario
```

8. Запустите команду `tox`. Убедитесь, что всё отработало успешно.

Ответ:
Все прошло успешно
```sh

PLAY RECAP *********************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Pruning extra files from scenario ephemeral directory
_____________________________________________________________________ summary _____________________________________________________________________
  py37-ansible210: commands succeeded
  py37-ansible30: commands succeeded
  py39-ansible210: commands succeeded
  py39-ansible30: commands succeeded
  congratulations :)
  
  ```

9. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.
Ответ:
добавлен тег tox версия 1.0.2


После выполнения у вас должно получится два сценария molecule и один tox.ini файл в репозитории. Не забудьте указать в ответе теги решений Tox и Molecule заданий. В качестве решения пришлите ссылку на  ваш репозиторий и скриншоты этапов выполнения задания. 

Ответ:
дефолтный и облегченный для токс сценарий добавлен 
