# Домашнее задание к занятию 3 «Использование Ansible»

## Подготовка к выполнению

1. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.
2. Репозиторий LightHouse находится [по ссылке](https://github.com/VKCOM/lighthouse).

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает LightHouse.
Ответ:
Добавил установку nginx и lighthouse

2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику LightHouse, установить Nginx или любой другой веб-сервер, настроить его конфиг для открытия LightHouse, запустить веб-сервер.

Ответ:
Поднял в тераформ еще один сервер под lighthouse
Работает, установлен 

4. Подготовьте свой inventory-файл `prod.yml`.

Ответ:
Готово

5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

Ответ:
Passed: 0 failure(s), 0 warning(s) on 1 files. Last profile that met the validation criteria was 'production'.


6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
Ответ:
Не понял на каком окружении запускать, запустил на prod
Не нашел rpm , но это нормально. чек не всегда все может

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
Ответ: 
Плейбук идемпотентен , есть замечание по очистке скаченного файла deb. Можно убрать данную таску. 

TASK [Remove downloaded .deb file] 
*******************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/tmp/vector_0.33.1-1_amd64.deb",
-    "state": "file"
+    "state": "absent"
 }

changed: [vector-01]


9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.

Приложил

10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

Ответ: готово

---