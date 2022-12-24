1. Vagrant установлен, команды halt, suspend, up , ssh выполнены успешны.
    Всё понятно , работал уже с ним.
    Прикладываю вывод в консоль

```sh
sa@lapt MINGW64 /q/vagrant/ubuntu20
$ vagrant suspend
==> default: Saving VM state and suspending execution...

sa@lapt MINGW64 /q/vagrant/ubuntu20
$ vagrant halt
==> default: Discarding saved state of VM...

sa@lapt MINGW64 /q/vagrant/ubuntu20
$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Checking if box 'bento/ubuntu-20.04' version '202212.11.0' is up to date...
==> default: Clearing any previously set forwarded ports...
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
==> default: Machine booted and ready!
==> default: Checking for guest additions in VM...
==> default: Mounting shared folders...
    default: /vagrant => Q:/vagrant/ubuntu20
==> default: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> default: flag to force provisioning. Provisioners marked to run always will still run.

sa@lapt MINGW64 /q/vagrant/ubuntu20
$ vagrant ssh
Welcome to Ubuntu 20.04.5 LTS (GNU/Linux 5.4.0-135-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sat 24 Dec 2022 12:19:02 PM UTC

  System load:  0.51               Processes:             124
  Usage of /:   12.2% of 30.34GB   Users logged in:       0
  Memory usage: 19%                IPv4 address for eth0: 10.0.2.15
  Swap usage:   0%


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
Last login: Fri Dec 23 20:18:00 2022 from 10.0.2.2
vagrant@vagrant:~$
```

2. Vagrant выделил на виртуальную машину Ubuntu
1 Gb RAM
2 CPU
64 Gb HDD

3.
Ознакомился
Сделал такой конфиг, выключил и включил машину , чтобы увеличить до 4 Gb и 4 CPU

```sh
Vagrant.configure("2") do |config|
        config.vm.box = "bento/ubuntu-20.04"
        config.vm.provider "virtualbox" do |v|
                v.memory = 4024
                v.cpus = 4
        end
end
```

4.
Набрал vagrant ssh попал внутр виртуальной машины в ОС Ubuntu 20
``` sh
$ vagrant ssh
Welcome to Ubuntu 20.04.5 LTS (GNU/Linux 5.4.0-135-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sat 24 Dec 2022 07:40:31 PM UTC

  System load:  0.0                Processes:             144
  Usage of /:   12.1% of 30.34GB   Users logged in:       0
  Memory usage: 6%                 IPv4 address for eth0: 10.0.2.15
  Swap usage:   0%


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
```
5.
Вывел man bash > bash.txt
И открыл в vi , чтобы также смотреть номер строк
дальше набрал в поиск /history
и клавишей n переходил читал везде где слово history попадается

Ответ:
Переменной history-size  , можно задать длину history
   history-size (unset)
``` sh
Set  the  maximum  number  of  history  entries  saved in the history list.  If set to zero, any existing history entries are
              deleted and no new entries are saved.  If set to a value less than zero, the number of history entries is  not  limited.   By
              default, the number of history entries is set to the value of the HISTSIZE shell variable.  If an attempt is made to set his‐
              tory-size to a non-numeric value, the maximum number of history entries will be set to 500.
Описание находится на 2181 строке

- ignoreboth
 A value of ignoreboth is shorthand for ignorespace and ignoredups.  A
  value of erasedups causes all previous lines matching the current line to be removed from the history list before  that  line
  is saved.  Any value not in the above list is ignored.  If HISTCONTROL is unset, or does not include a valid value, all lines
  read by the shell parser are saved on the history list, subject to the value of HISTIGNORE.  The second and subsequent  lines
  of a multi-line compound command are not tested, and are added to the history regardless of the value of HISTCONTROL.
```

Значение ignoreboth является сокращением для ignorespace и ignoredups значение erasedups приводит к тому, что все предыдущие строки, совпадающие с текущей строкой, удаляются из списка истории перед этой строкой.
сохраняется. Любое значение, не входящее в приведенный выше список, игнорируется. Если HISTCONTROL не установлен или не включает допустимое значение, все строки
прочитанные синтаксическим анализатором оболочки, сохраняются в списке истории, в зависимости от значения HISTIGNORE. Вторая и последующие строки
многострочной составной команды не проверяются и добавляются в историю независимо от значения HISTCONTROL.

6.
Это механизм генерации строк.
Подробное описание в мануале начинается на  строке 979.
Описание
``` sh
Brace Expansion
       Brace  expansion  is  a mechanism by which arbitrary strings may be generated.  This mechanism is similar to pathname expansion, but
       the filenames generated need not exist.  Patterns to be brace expanded take the form of an optional preamble, followed by  either  a
       series of comma-separated strings or a sequence expression between a pair of braces, followed by an optional postscript.  The pream‐
       ble is prefixed to each string contained within the braces, and the postscript is then appended to each resulting string,  expanding
       left to right.

       Brace expansions may be nested.  The results of each expanded string are not sorted; left to right order is preserved.  For example,
       a{d,c,b}e expands into `ade ace abe'.
    
       A sequence expression takes the form {x..y[..incr]}, where x and y are either integers or single characters, and incr,  an  optional
       increment,  is  an integer.  When integers are supplied, the expression expands to each number between x and y, inclusive.  Supplied
       integers may be prefixed with 0 to force each term to have the same width.  When either x or y begins with a  zero,  the  shell  at‐
       tempts  to  force  all generated terms to contain the same number of digits, zero-padding where necessary.  When characters are sup‐
       plied, the expression expands to each character lexicographically between x and y, inclusive, using the default C locale.  Note that
       both x and y must be of the same type.  When the increment is supplied, it is used as the difference between each term.  The default
       increment is 1 or -1 as appropriate.
    
       Brace expansion is performed before any other expansions, and any characters special to other expansions are preserved  in  the  re‐
       sult.  It is strictly textual.  Bash does not apply any syntactic interpretation to the context of the expansion or the text between
       the braces.
    
       A correctly-formed brace expansion must contain unquoted opening and closing braces, and at least one unquoted comma or a valid  se‐
       quence  expression.   Any  incorrectly formed brace expansion is left unchanged.  A { or , may be quoted with a backslash to prevent
       its being considered part of a brace expression.  To avoid conflicts with parameter expansion, the string ${ is not considered  eli‐
       gible for brace expansion, and inhibits brace expansion until the closing }.
    
       This  construct is typically used as shorthand when the common prefix of the strings to be generated is longer than in the above ex‐
       ample:
    
              mkdir /usr/local/src/bash/{old,new,dist,bugs}
       or
              chown root /usr/{ucb/{ex,edit},lib/{ex?.?*,how_ex}}
    
       Brace expansion introduces a slight incompatibility with historical versions of sh.  sh does not treat  opening  or  closing  braces
       specially  when they appear as part of a word, and preserves them in the output.  Bash removes braces from words as a consequence of
       brace expansion.  For example, a word entered to sh as file{1,2} appears identically in the output.  The  same  word  is  output  as
       file1 file2 after expansion by bash.  If strict compatibility with sh is desired, start bash with the +B option or disable brace ex‐
       pansion with the +B option to the set command (see SHELL BUILTIN COMMANDS below).
```

7.
touch {1..100000} - получится создать
touch {1..100000} - не получится -bash: /usr/bin/touch: Argument list too long
Аргумент для листа слишком большой


8. Нащёл про [[-d в мануале следующее
``` sh
CONDITIONAL EXPRESSIONS
       Conditional  expressions are used by the [[ compound command and the test and [ builtin commands to test file attributes and perform
       string and arithmetic comparisons.  The test abd [ commands determine their behavior based on the number of arguments; see  the  de‐
       scriptions of those commands for any other command-specific actions.

       Expressions are formed from the following unary or binary primaries.  Bash handles several filenames specially when they are used in
       expressions.  If the operating system on which bash is running provides these special files, bash will use them; otherwise  it  will
       emulate  them  internally  with  this behavior: If any file argument to one of the primaries is of the form /dev/fd/n, then file de‐
       scriptor n is checked.  If the file argument to one of the primaries is one of /dev/stdin, /dev/stdout,  or  /dev/stderr,  file  de‐
       scriptor 0, 1, or 2, respectively, is checked.
       
       Unless otherwise specified, primaries that operate on files follow symbolic links and operate on the target of the link, rather than
       the link itself.
       
       When used with [[, the < and > operators sort lexicographically using the current locale.  The test command sorts using ASCII order‐
       ing.
       
       -a file
              True if file exists.
       -b file
              True if file exists and is a block special file.
       -c file
              True if file exists and is a character special file.
       -d file
              True if file exists and is a directory.
       -e file
              True if file exists.
       -f file
              True if file exists and is a regular file.
       -g file
```

[[ -d /tmp ]] - проверяет есть ли каталог по пути /tmp

Пример,
``` sh
vagrant@vagrant:~$ if [[ -d /tmp ]]; then echo "есть"; else echo "нет"; fi
есть
```

9.
Создал катало, скоировал bash, добавил новый каталог в путь вперёд.
``` sh
vagrant@vagrant:~$ mkdir /tmp/new_path_dir/
vagrant@vagrant:~$ cp /bin/bash /tmp/new_path_dir/
vagrant@vagrant:~$ PATH=/tmp/new_path_dir/:$PATH
vagrant@vagrant:~$ type -a bash
bash is /tmp/new_path_dir/bash
bash is /usr/bin/bash
``` 

10.
Судя по мануалу
``` sh
 man batch

       at      executes commands at a specified time.
       batch   executes commands when system load levels permit; in other words, when the load average drops below 1.5, or the value specified in the invocation of atd.
```

at запускает команду в установленное время
batch - запускает команду когда загрузка системы опускается ниже 1.5

11. Выполнил
vagrant halt

