# Домашнее задание к занятию 1 «Введение в Ansible»

## Подготовка к выполнению

1. Установите Ansible версии 2.10 или выше.
2. Создайте свой публичный репозиторий на GitHub с произвольным именем.
3. Скачайте [Playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

## Основная часть

1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте значение, которое имеет факт `some_fact` для указанного хоста при выполнении playbook.

Ответ:

```sh
ansible-playbook -i inventory/test.yml site.yml
```
Ответ:
12


2. Найдите файл с переменными (group_vars), в котором задаётся найденное в первом пункте значение, и поменяйте его на `all default fact`.
Ответ:

Нашел, поменял
```sh
TASK [Print fact] ***********************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}
```

3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.

Ответ:
Поднял при помощиd docker-compose (docker-compose.yml)
```sh
version: '3'
services:
  centos:
    image: centos:7
    container_name: centos
    restart: unless-stopped
    entrypoint: "sleep infinity"

  ubuntu:
    image: ubuntu
    container_name: ubuntu
    restart: unless-stopped
    entrypoint: "sleep infinity"
```

```sh
docker-compose up -d
```

Долил python3 для убунты , так как не хватает его в образе
```sh
docker exec -it ubuntu apt-get update
docker exec -it ubuntu apt-get install python3 -y
```


4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
Ответ:

Запустил плейбук
```sh
ansible-playbook -i inventory/prod.yml site.yml
```

Результат:

```sh

TASK [Print OS] ********************************************************************************************************************************************
ok: [centos] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************************************************
ok: [centos] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

```

5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились значения: для `deb` — `deb default fact`, для `el` — `el default fact`.

Ответ:
Добавил в каждый examp.yml

```sh
TASK [Print fact] ******************************************************************************************************************************************
ok: [centos] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
```

6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
Ответ:
Все нормально

7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
Ответ:

```sh
ansible-vault encrypt group_vars/deb/examp.yml
ansible-vault encrypt group_vars/el/examp.yml
```

Задал пароль вручную 
```sh
New Vault password: 
Confirm New Vault password: 
Encryption successful
```


8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
Ответ:

Указал ключ
```sh
ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
```

```sh
PLAY RECAP *************************************************************************************************************************************************
centos                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```


9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
Ответ:
ansible-doc -l -t connection

Исправление:
Я выбрал ansible.builtin.local и его прописал в prod.yml

```sh
  local:
    hosts:
      localhost:
        ansible_connection: local

```

```sh
xxx playbook % ansible-doc  -l -t connection
ansible.builtin.local          execute on controller                                                                                                   
ansible.builtin.paramiko_ssh   Run tasks via python ssh (paramiko)                                                                                     
ansible.builtin.psrp           Run tasks over Microsoft PowerShell Remoting Protocol                                                                   
ansible.builtin.ssh            connect via SSH client binary                                                                                           
ansible.builtin.winrm          Run tasks over Microsoft's WinRM                                                                                        
ansible.netcommon.grpc         Provides a persistent connection using the gRPC protocol                                                                
ansible.netcommon.httpapi      Use httpapi to run command on network appliances                                                                        
ansible.netcommon.libssh       Run tasks using libssh for ssh connection                                                                               
ansible.netcommon.netconf      Provides a persistent connection using the netconf protocol                                                             
ansible.netcommon.network_cli  Use network_cli to run command on network appliances                                                                    
ansible.netcomm
```

10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
Ответ:

prod.yml:
```sh
---
  el:
    hosts:
      centos:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker
  local:
    hosts:
      localhost:
        ansible_connection: ansible.builtin.local
```


11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь, что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
```sh
ok: [centos] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [localhost] => {
    "msg": "MacOSX"
}

TASK [Print fact] ******************************************************************************************************************************************
ok: [centos] => {
    "msg": "el default fact"
}
ok: [localhost] => {
    "msg": "all default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
```

12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

Ответ:
готово



## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот вариант](https://hub.docker.com/r/pycontribs/fedora).
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
6. Все изменения должны быть зафиксированы и отправлены в ваш личный репозиторий.

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
