# Домашнее задание к занятию 1. «Типы и структура СУБД»

## Задача 1

Архитектор ПО решил проконсультироваться у вас, какой тип БД 
лучше выбрать для хранения определённых данных.

Он вам предоставил следующие типы сущностей, которые нужно будет хранить в БД:

- электронные чеки в json-виде,
- склады и автомобильные дороги для логистической компании,
- генеалогические деревья,
- кэш идентификаторов клиентов с ограниченным временем жизни для движка аутенфикации,
- отношения клиент-покупка для интернет-магазина.

Выберите подходящие типы СУБД для каждой сущности и объясните свой выбор.

Ответ:
1) документно-ориентированную MongoDB, созданна для хранения и извлечения документов в JSON
2) графовую БД , для поиска отпимального маршрута , не видел в реальности ни одну такую 
3) сетевая СУБД - не знаю с ними не сталкивался но вроде как для этого 
4) key-value  , Redis самая популярная и быстрая , отлично подойдет и используется для подобных кейсов
5) Реляционную РСУБД например Postgresql - здесь важна транзакционная целостность данных , поэтому реляционная для таких целей самое то 



## Задача 2

Вы создали распределённое высоконагруженное приложение и хотите классифицировать его согласно 
CAP-теореме. Какой классификации по CAP-теореме соответствует ваша система, если 
(каждый пункт — это отдельная реализация вашей системы и для каждого пункта нужно привести классификацию):

- данные записываются на все узлы с задержкой до часа (асинхронная запись);
- при сетевых сбоях система может разделиться на 2 раздельных кластера;x
- система может не прислать корректный ответ или сбросить соединение.

Согласно PACELC-теореме как бы вы классифицировали эти реализации?

Ответ:
По CAP:
1) НЕПРАВИЛЬНЫЙ ОТВЕТ - CP обеспечивается согласованность и устойчивость к разделению в ущерб доступности

ПРАВИЛЬНЫЙ ОТВЕТ ЭТО AP
В случае, когда данные записываются на все узлы с задержкой до часа (асинхронная запись), означает, что система выбирает доступность и разделение (Availability, Partition tolerance) как приоритеты над согласованностью (Consistency). То есть, система может допускать некоторую несогласованность данных в пользу обеспечения доступности и устойчивости к разделению.
Правильный ответ - это AP-система (Availability + Partition tolerance — Consistency) 


2) AP - доступность и устойчивость к разделению. но в ущерб согласованности
"- при сетевых сбоях система может разделиться на 2 раздельных кластера;"
Комментарий:
Я считаю что это все таки AP 
так как по cap свойства: согласованность (consistency), доступность (availability) и устойчивостью к разделению (partition tolerance). Если система разделяется на два раздельных кластера при сетевых сбоях, то это однозно означает, что она обладает устойчивостью к разделению (partition tolerance). В такой ситуации система может продолжать работать независимо на каждом из кластеров, даже если связь или коммуникация между ними прерывается. Кроме этого сохраняется доступность системы то есть выполняется A. Поэтому правильный ответ из того краткого описания что приведено  это всё таки AP. 

3) CP - согласованность и устойчивость

По PACELC:
1) PC/EC
2) PA/EL 
3) PC/EC

## Задача 3

Могут ли в одной системе сочетаться принципы BASE и ACID? Почему?

Ответ:
Нет не могут . так как BASE ориентирован на производительность системы а ACID - это строгая сохранность данных. 


## Задача 4

Вам дали задачу написать системное решение, основой которого бы послужили:

- фиксация некоторых значений с временем жизни,
- реакция на истечение таймаута.

Вы слышали о key-value-хранилище, которое имеет механизм Pub/Sub. 
Что это за система? Какие минусы выбора этой системы?

Ответ: 
Речь видимо про Redis, самая известная key-value СУБД , Pub/Sub это брокер сообщений (брокер событий в ней). 
Обладает очень высокой производительностью, если работает в режиме оперативной памяти ,соответственно хранить что то оченоь важное в таком режиме не стоит - можно использовать для сессий
По поводу использования его как броке сообщений используя механизмы Pub/Sub , на мой взгляд лучше использовать более продвинутые решения такие как RabbitMq, Kafka . 

