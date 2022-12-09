1. Найдите полный хеш и комментарий коммита, хеш которого начинается на aefea.

Команда:
git show aefea

Выдаёт требуемый коммит:


    aefead2207ef7e2aa5dc81a34aedf0cad4c32545
    Update CHANGELOG.md

2. Какому тегу соответствует коммит 85024d3?



Команда:
$ git show 85024d3

Выдаёт ответ в котором в скобках указано какой тэг:
commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)

v0.12.23

3. Сколько родителей у коммита b8d720? Напишите их хеши.


Команда: 
git show b8d720

Возвращает результат в строчке Merge которой указаны хэши родительских коммитов

$ git show b8d720
commit b8d720f8340221f2146e4e4870bf2ee0bc48f2d5
Merge: 56cd7859e0 9ea88f22fc


2 родителя
Merge: 
56cd7859e0 
9ea88f22fc

4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.

Команда:
$ git log 85024d3100126de36331c6982bfaac02cdab9e76...33ff1c03bb960b332be3af2e333462dde88b279e --oneline

Вовзращает готовый результат:


33ff1c03bb (tag: v0.12.24) v0.12.24
b14b74c493 [Website] vmc provider links
3f235065b9 Update CHANGELOG.md
6ae64e247b registry: Fix panic when server is unreachable
5c619ca1ba website: Remove links to the getting started guide's old location
06275647e2 Update CHANGELOG.md
d5f9411f51 command: Fix bug when using terraform login on Windows
4b6d06cc5d Update CHANGELOG.md
dd01a35078 Update CHANGELOG.md
225466bc3e Cleanup after v0.12.23 release


5. Найдите коммит в котором была создана функция func providerSource, ее определение в коде выглядит так func providerSource(...) (вместо троеточия перечислены аргументы).


Команда:

$ git log -S"func providerSource(" --oneline
8c928e8358 main: Consult local directories as potential mirrors of providers

Находит коммиты в файлах которых есть func providerSource( елси бы вернула несколько комитов, надо смотреть самый ранний , очевидно это и есть время создания данной функции



6. Найдите все коммиты в которых была изменена функция globalPluginDirs.

Пересмотрел прошлый результат свой, порядок действий такой

Командой:

$ git log -S"globalPluginDirs" --oneline

Нашёл коммиты которые требуют изучения , дальше каждый коммит просмотрел при помощи команды 

git show 

125eb51dc4 Remove accidentally-committed binary
22c121df86 Bump compatibility version to 1.3.0 for terraform core release (#30988)
35a058fb3d main: configure credentials from the CLI config file
c0b1761096 prevent log output during init
8364383c35 Push plugin discovery down into command package


В итоге 
Ответ:
в коммите 8364383c35 шло изменение данной фукнции globalPluginDirs


7. Кто автор функции synchronizedWriters?
git log -S"func synchronizedWriters"

commit 5ac311e2a91e381e2f52234668b49ba670aa0fe5
Author: Martin Atkins <mart@degeneration.co.uk>
