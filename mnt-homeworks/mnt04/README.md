# Домашнее задание к занятию 4 «Работа с roles»

## Подготовка к выполнению

1. * Необязательно. Познакомьтесь с [LightHouse](https://youtu.be/ymlrNlaHzIY?t=929).
2. Создайте два пустых публичных репозитория в любом своём проекте: vector-role и lighthouse-role.
3. Добавьте публичную часть своего ключа к своему профилю на GitHub.

## Основная часть

Ваша цель — разбить ваш playbook на отдельные roles. 

Задача — сделать roles для ClickHouse, Vector и LightHouse и написать playbook для использования этих ролей. 

Ожидаемый результат — существуют три ваших репозитория: два с roles и один с playbook.

**Что нужно сделать**

1. Создайте в старой версии playbook файл `requirements.yml` и заполните его содержимым:

   ```yaml
   ---
     - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
       scm: git
       version: "1.13"
       name: clickhouse 
   ```

Ответ:
создал

2. При помощи `ansible-galaxy` скачайте себе эту роль.

Ответ:
скачал 
```sh
ansible-galaxy install -r requirements.yml
```

3. Создайте новый каталог с ролью при помощи `ansible-galaxy role init vector-role`.

```sh
ansible-galaxy role init vector-role
```

Готово

4. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`. 

Ответ:

Готово, раскидал  

5. Перенести нужные шаблоны конфигов в `templates`.

Ответ: готово

6. Опишите в `README.md` обе роли и их параметры. Пример качественной документации ansible role [по ссылке](https://github.com/cloudalchemy/ansible-prometheus).

Ответ: готово

7. Повторите шаги 3–6 для LightHouse. Помните, что одна роль должна настраивать один продукт.

Ответ: готово

Поднял терафамормов машины и протестировал что все работает, плейбук выглядит теперь вот так:
Из замечаний отметил бы что nginx ставится вместе с lighthouse по идее наверное выглядит не совсем корректно , с другой стороны lighthouse требует какой то вебсервер который обработает его статику , поэтому в целом нормально думаю 


```sh
---
- name: Install Vector
  hosts: vector
  become: true
  roles:
  - vector-role
  tasks:
  - name: Ping host
    ansible.builtin.ping:

- name: Install Clickhouse
  hosts: clickhouse
  become: true
  roles:
    - clickhouse

- name: Install Lighthouse
  hosts: lighthouse
  become: true
  roles:
    - lighthouse-role
```


8. Выложите все roles в репозитории. Проставьте теги, используя семантическую нумерацию. Добавьте roles в `requirements.yml` в playbook.
Ответ: 
готово


9. Переработайте playbook на использование roles. Не забудьте про зависимости LightHouse и возможности совмещения `roles` с `tasks`.

Ответ:
готово, добавил для примера таску ping для демонстрации процесса совмещения ролей и тасок

10. Выложите playbook в репозиторий.
Ответ: готово

11. В ответе дайте ссылки на оба репозитория с roles и одну ссылку на репозиторий с playbook.
Ответ: 
хорошо



---
