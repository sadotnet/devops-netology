# Домашнее задание к занятию 4. «PostgreSQL»

## Задача 1

Используя Docker, поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
Подключитесь к БД PostgreSQL, используя `psql`.
Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.


**Найдите и приведите** управляющие команды для:

- вывода списка БД,
- подключения к БД,
- вывода списка таблиц,
- вывода описания содержимого таблиц,
- выхода из psql.

Ответ:

```sh
docker run --name postgresql \
    -e POSTGRES_PASSWORD=password \
    -v my_data:/var/lib/postgresql/data \
    -p 5432:5432 \
    -d postgres:13

#Подключитесь к БД PostgreSQL используя psql.
docker exec -it postgresql bash

#root@vm02:~# docker exec -it postgresql bash
#root@a420b1c2bf44:/# 

psql -U postgres

```
- вывода списка БД,

```sh
postgres=# \l+
                                                                   List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   |  Size   | Tablespace |                Description                 
-----------+----------+----------+------------+------------+-----------------------+---------+------------+--------------------------------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |                       | 7909 kB | pg_default | default administrative connection database
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +| 7761 kB | pg_default | unmodifiable empty database
           |          |          |            |            | postgres=CTc/postgres |         |            | 
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +| 7761 kB | pg_default | default template for new databases
```

- подключения к БД,

```sh
postgres=# \conninfo
You are connected to database "postgres" as user "postgres" via socket in "/var/run/postgresql" at port "5432".
```


- вывода списка таблиц,

```sh
postgres=# \dtS
                    List of relations
   Schema   |          Name           | Type  |  Owner   
------------+-------------------------+-------+----------
 pg_catalog | pg_aggregate            | table | postgres
 pg_catalog | pg_am                   | table | postgres
 pg_catalog | pg_amop                 | table | postgres
 pg_catalog | pg_amproc               | table | postgres
 pg_catalog | pg_attrdef              | table | postgres
 pg_catalog | pg_attribute            | table | postgres
 pg_catalog | pg_auth_members         | table | postgres
 pg_catalog | pg_authid               | table | postgres
 pg_catalog | pg_cast                 | table | postgres
...
```

- вывода описания содержимого таблиц,

```sh
postgres=# \dS+
                                            List of relations
   Schema   |              Name               | Type  |  Owner   | Persistence |    Size    | Description 
------------+---------------------------------+-------+----------+-------------+------------+-------------
 pg_catalog | pg_aggregate                    | table | postgres | permanent   | 56 kB      | 
 pg_catalog | pg_am                           | table | postgres | permanent   | 40 kB      | 
 pg_catalog | pg_amop                         | table | postgres | permanent   | 80 kB      | 
 pg_catalog | pg_amproc                       | table | postgres | permanent   | 64 kB      | 
 pg_catalog | pg_attrdef                      | table | postgres | permanent   | 8192 bytes | 
 pg_catalog | pg_attribute                    | table | postgres | permanent   | 456 kB     | 
 ```

- выхода из psql.
```sh
postgres=# \q
root@a420b1c2bf44:/# 
```




## Задача 2

Используя `psql`, создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/virt-11/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления, и полученный результат.


Ответ:
```sh
root@a420b1c2bf44:/# psql -U postgres
psql (13.12 (Debian 13.12-1.pgdg120+1))
Type "help" for help.

postgres=# 
postgres=#  CREATE DATABASE test_database;
CREATE DATABASE
postgres=# 
```

```sh
root@vm02:~# docker cp /home/vagrant/test_dump.sql postgresql:/tmp
root@vm02:~# 
root@vm02:~# docker exec -it postgresql bash
root@a420b1c2bf44:/# 
root@a420b1c2bf44:/# psql -U postgres test_database < /tmp/test_dump.sql
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval 
--------
      8
(1 row)

ALTER TABLE
root@a420b1c2bf44:/# 
root@a420b1c2bf44:/# 
root@a420b1c2bf44:/# 

```


```sh
root@a420b1c2bf44:/# 
root@a420b1c2bf44:/# psql -U postgres
psql (13.12 (Debian 13.12-1.pgdg120+1))
Type "help" for help.

postgres=# \c test_database 
You are now connected to database "test_database" as user "postgres".
test_database=# \dt
         List of relations
 Schema |  Name  | Type  |  Owner   
--------+--------+-------+----------
 public | orders | table | postgres
(1 row)
```

Анализ используя таблицу pg_stats
```sh
root@a420b1c2bf44:/# psql -U postgres
psql (13.12 (Debian 13.12-1.pgdg120+1))
Type "help" for help.

postgres=# \c test_database 
You are now connected to database "test_database" as user "postgres".
test_database=# \dt
         List of relations
 Schema |  Name  | Type  |  Owner   
--------+--------+-------+----------
 public | orders | table | postgres
(1 row)

test_database=# ANALYZE public.orders;
ANALYZE
test_database=# select tablename, attname, avg_width from pg_stats where tablename = 'orders';
 tablename | attname | avg_width 
-----------+---------+-----------
 orders    | id      |         4
 orders    | title   |        16
 orders    | price   |         4
(3 rows)
```
Наибольшее среднее значение размера элементов в байтах у поля title 


## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам как успешному выпускнику курсов DevOps в Нетологии предложили
провести разбиение таблицы на 2: шардировать на orders_1 - price>499 и orders_2 - price<=499.

Предложите SQL-транзакцию для проведения этой операции.

Ответ:
Для разбиения на шарды создадим новые таблицы orders_1 и orders_2. 

```sh
-- orders_1: price>499
CREATE TABLE orders_1 (CHECK (price > 499)) INHERITS (orders);
INSERT INTO orders_1 SELECT * FROM orders where price > 499;

-- orders_2: price<=499
CREATE TABLE orders_2 (CHECK (price <= 499)) INHERITS (orders);
INSERT INTO orders_2 SELECT * FROM orders where price <= 499;
```

Можно ли было изначально исключить ручное разбиение при проектировании таблицы orders?

Ответ:

Да можно создать правила
```sh
CREATE RULE orders_insert_to_1 AS ON INSERT TO orders WHERE ( price > 499 ) DO INSTEAD INSERT INTO orders_1 VALUES (NEW.*);
CREATE RULE orders_insert_to_2 AS ON INSERT TO orders WHERE ( price <= 499 ) DO INSTEAD INSERT INTO orders_2 VALUES (NEW.*);
```

Ответ преподавателя:
```sh
По поводу исключения ручного разбиения, если изначально известен принцип разделения данных, к примеру, это таблица продаж в маркетплейсе и данные надо делить по дням, то лучше всего создать партицированную таблицу с соответствующими секциями. Тогда не надо создавать никаких дополнительных правил.
```


## Задача 4

Используя утилиту `pg_dump`, создайте бекап БД `test_database`.
Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

```sh
export PGPASSWORD=password && pg_dump -h localhost -U postgres test_database > /tmp/test_dump_new.sql
```

Добавил бы UNIQUE 

```sh
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL UNIQUE,
    price integer DEFAULT 0
);
```

