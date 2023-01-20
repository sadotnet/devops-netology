# Домашнее задание к занятию "3.5. Файловые системы"

### Цель задания

В результате выполнения этого задания вы: 

1. Научитесь работать с инструментами разметки жестких дисков, виртуальных разделов - RAID массивами и логическими томами, конфигурациями файловых систем. Основная задача - понять, какие слои абстракций могут нас отделять от файловой системы до железа. Обычно инженер инфраструктуры не сталкивается напрямую с настройкой LVM или RAID, но иметь понимание, как это работает - необходимо.
1. Создадите нештатную ситуацию работы жестких дисков и поймете, как система RAID обеспечивает отказоустойчивую работу.


### Чеклист готовности к домашнему заданию

1. Убедитесь, что у вас на новой виртуальной машине (шаг 3 задания) установлены следующие утилиты - `mdadm`, `fdisk`, `sfdisk`, `mkfs`, `lsblk`, `wget`.  
2. Воспользуйтесь пакетным менеджером apt для установки необходимых инструментов


### Инструменты/ дополнительные материалы, которые пригодятся для выполнения задания

1. Разряженные файлы - [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB)
2. [Подробный анализ производительности RAID,3-19 страницы](https://www.baarf.dk/BAARF/0.Millsap1996.08.21-VLDB.pdf).
3. [RAID5 write hole](https://www.intel.com/content/www/us/en/support/articles/000057368/memory-and-storage.html).


------

## Задание

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.

Ответ:
Разрежённый файл (англ. sparse file) — файл, в котором последовательности нулевых байтов заменены на информацию об этих последовательностях (список дыр).

2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

3. Ответ:
нет, не может, потому жёсткая ссылка указывает на один Inode
Создал жёсткую ссылку на файл readme.txt под названием hardlink, поменял права и владельца, сделал команду stat до и после и на саму hardlink
Убедился через команду stat 

```shell
root@vagrant:~# touch readme.txt
root@vagrant:~# ln readme.txt hardlink

root@vagrant:~# stat readme.txt
  File: readme.txt
  Size: 0           Blocks: 0          IO Block: 4096   regular empty file
Device: fd00h/64768d  Inode: 1179667     Links: 2
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2023-01-15 08:42:00.635541557 +0000
Modify: 2023-01-15 08:42:00.635541557 +0000
Change: 2023-01-15 08:42:33.667017558 +0000
 Birth: -
root@vagrant:~#
root@vagrant:~#
root@vagrant:~# chmod 777 readme.txt
root@vagrant:~# chown vagrant: readme.txt
root@vagrant:~# stat readme.txt
  File: readme.txt
  Size: 0           Blocks: 0          IO Block: 4096   regular empty file
Device: fd00h/64768d  Inode: 1179667     Links: 2
Access: (0777/-rwxrwxrwx)  Uid: ( 1000/ vagrant)   Gid: ( 1000/ vagrant)
Access: 2023-01-15 08:42:00.635541557 +0000
Modify: 2023-01-15 08:42:00.635541557 +0000
Change: 2023-01-15 08:43:30.674499554 +0000
 Birth: -
root@vagrant:~# stat hardlink
  File: hardlink
  Size: 0           Blocks: 0          IO Block: 4096   regular empty file
Device: fd00h/64768d  Inode: 1179667     Links: 2
Access: (0777/-rwxrwxrwx)  Uid: ( 1000/ vagrant)   Gid: ( 1000/ vagrant)
Access: 2023-01-15 08:42:00.635541557 +0000
Modify: 2023-01-15 08:42:00.635541557 +0000
Change: 2023-01-15 08:43:30.674499554 +0000
```

3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```ruby
    path_to_disk_folder = './disks'

    host_params = {
        'disk_size' => 2560,
        'disks'=>[1, 2],
        'cpus'=>2,
        'memory'=>2048,
        'hostname'=>'sysadm-fs',
        'vm_name'=>'sysadm-fs'
    }
    Vagrant.configure("2") do |config|
        config.vm.box = "bento/ubuntu-20.04"
        config.vm.hostname=host_params['hostname']
        config.vm.provider :virtualbox do |v|

            v.name=host_params['vm_name']
            v.cpus=host_params['cpus']
            v.memory=host_params['memory']

            host_params['disks'].each do |disk|
                file_to_disk=path_to_disk_folder+'/disk'+disk.to_s+'.vdi'
                unless File.exist?(file_to_disk)
                    v.customize ['createmedium', '--filename', file_to_disk, '--size', host_params['disk_size']]
                end
                v.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', disk.to_s, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
            end
        end
        config.vm.network "private_network", type: "dhcp"
    end
    ```

    Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.
Ответ:
Сделал:
```shell
root@sysadm-fs:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0                       7:0    0   62M  1 loop /snap/core20/1611
loop1                       7:1    0   47M  1 loop /snap/snapd/16292
loop2                       7:2    0 67.8M  1 loop /snap/lxd/22753
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    2G  0 part /boot
└─sda3                      8:3    0   62G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0   31G  0 lvm  /
sdb                         8:16   0  2.5G  0 disk
sdc                         8:32   0  2.5G  0 disk
```

4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.
```shell
# Создаю первый раздел на диске в 2 Гб
root@sysadm-fs:~# sudo fdisk /dev/sdb

Welcome to fdisk (util-linux 2.34).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x8036ffb2.

Command (m for help): ^C
Do you really want to quit? q

root@sysadm-fs:~#
root@sysadm-fs:~#
root@sysadm-fs:~# fdisk /dev/sdb

Welcome to fdisk (util-linux 2.34).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x74e3a75e.

Command (m for help): m

Help:

  DOS (MBR)
   a   toggle a bootable flag
   b   edit nested BSD disklabel
   c   toggle the dos compatibility flag

  Generic
   d   delete a partition
   F   list free unpartitioned space
   l   list known partition types
   n   add a new partition
   p   print the partition table
   t   change a partition type
   v   verify the partition table
   i   print information about a partition

  Misc
   m   print this menu
   u   change display/entry units
   x   extra functionality (experts only)

  Script
   I   load disk layout from sfdisk script file
   O   dump disk layout to sfdisk script file

  Save & Exit
   w   write table to disk and exit
   q   quit without saving changes

  Create a new label
   g   create a new empty GPT partition table
   G   create a new empty SGI (IRIX) partition table
   o   create a new empty DOS partition table
   s   create a new empty Sun partition table


Command (m for help): p
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x74e3a75e

Command (m for help): g
Created a new GPT disklabel (GUID: A7F5B43A-F507-0340-A576-8C28DE48ADD2).

Command (m for help): n
Partition number (1-128, default 1):
First sector (2048-5242846, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242846, default 5242846): +2G

Created a new partition 1 of type 'Linux filesystem' and of size 2 GiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

# второй раздел на диске
root@sysadm-fs:~# sudo fdisk /dev/sdb

Welcome to fdisk (util-linux 2.34).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): p
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: A7F5B43A-F507-0340-A576-8C28DE48ADD2

Device     Start     End Sectors Size Type
/dev/sdb1   2048 4196351 4194304   2G Linux filesystem

Command (m for help): n
Partition number (2-128, default 2): 2
First sector (4196352-5242846, default 4196352):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242846, default 5242846):

Created a new partition 2 of type 'Linux filesystem' and of size 511 MiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.
```shell
root@sysadm-fs:~# sfdisk -d /dev/sdb | sfdisk /dev/sdc
Checking that no-one is using this disk right now ... OK

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new GPT disklabel (GUID: A7F5B43A-F507-0340-A576-8C28DE48ADD2).
/dev/sdc1: Created a new partition 1 of type 'Linux filesystem' and of size 2 GiB.
/dev/sdc2: Created a new partition 2 of type 'Linux filesystem' and of size 511 MiB.
/dev/sdc3: Done.

New situation:
Disklabel type: gpt
Disk identifier: A7F5B43A-F507-0340-A576-8C28DE48ADD2

Device       Start     End Sectors  Size Type
/dev/sdc1     2048 4196351 4194304    2G Linux filesystem
/dev/sdc2  4196352 5242846 1046495  511M Linux filesystem

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```
6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.
```shell
# Запустил процесс создания RAID1 
root@sysadm-fs:~# mdadm --create --verbose /dev/md1 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 2094080K
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
root@sysadm-fs:~#
root@sysadm-fs:~#
root@sysadm-fs:~#
root@sysadm-fs:~# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md1 : active raid1 sdc1[1] sdb1[0]
      2094080 blocks super 1.2 [2/2] [UU]
      [=================>...]  resync = 86.0% (1801856/2094080) finish=0.0min speed=225232K/sec
unused devices: <none>
# Готово
root@sysadm-fs:~# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md1 : active raid1 sdc1[1] sdb1[0]
      2094080 blocks super 1.2 [2/2] [UU]
```
7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.
```shell
root@sysadm-fs:~# mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 /dev/sdb2 /dev/sdc2
mdadm: chunk size defaults to 512K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
root@sysadm-fs:~#
root@sysadm-fs:~#
root@sysadm-fs:~# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md0 : active raid0 sdc2[1] sdb2[0]
      1041408 blocks super 1.2 512k chunks

md1 : active raid1 sdc1[1] sdb1[0]
      2094080 blocks super 1.2 [2/2] [UU]
```

8. Создайте 2 независимых PV на получившихся md-устройствах.
Хорошее описание:
https://www.dmosk.ru/instruktions.php?object=lvm

```shell
root@sysadm-fs:~#
root@sysadm-fs:~# pvcreate /dev/md1 /dev/md0
  Physical volume "/dev/md1" successfully created.
  Physical volume "/dev/md0" successfully created.
root@sysadm-fs:~# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda3
  VG Name               ubuntu-vg
  PV Size               <62.00 GiB / not usable 0
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              15871
  Free PE               7936
  Allocated PE          7935
 "/dev/md0" is a new physical volume of "1017.00 MiB"
  --- NEW Physical volume ---
  PV Name               /dev/md0
  VG Name
  PV Size               1017.00 MiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               JArMzC-IEt5-moar-KkNw-p3h2-v13L-11NzTf
  "/dev/md1" is a new physical volume of "<2.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/md1
  VG Name
  PV Size               <2.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               evMJ3C-yVCN-5bmE-jxNx-ohM8-GedK-Jhev7x
```

9. Создайте общую volume-group на этих двух PV.
```shell
root@sysadm-fs:~# vgcreate vg01 /dev/md1 /dev/md0
  Volume group "vg01" successfully created
root@sysadm-fs:~# vgdisplay
  --- Volume group ---
  VG Name               ubuntu-vg
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <62.00 GiB
  PE Size               4.00 MiB
  Total PE              15871
  Alloc PE / Size       7935 / <31.00 GiB
  Free  PE / Size       7936 / 31.00 GiB
  VG UUID               UZfqXZ-997r-hT24-kqSU-tjd6-fB2t-Up7O0f

  --- Volume group ---
  VG Name               vg01
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <2.99 GiB
  PE Size               4.00 MiB
  Total PE              765
  Alloc PE / Size       0 / 0
  Free  PE / Size       765 / <2.99 GiB
  VG UUID               AyrdV9-HFnZ-O576-soqA-T4FM-u6Y0-zXyzLZ


```

10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.
```shell
root@sysadm-fs:~# sudo lvcreate -L 100M vg01 /dev/md0
  Logical volume "lvol0" created.
```

11. Создайте `mkfs.ext4` ФС на получившемся LV.
```shell
root@sysadm-fs:~# mkfs.ext4 /dev/vg01/lvol0
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done
Writing inode tables: done
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done

root@sysadm-fs:~#
```

12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.
```shell
root@sysadm-fs:~# mkdir /tmp/new
root@sysadm-fs:~# mount /dev/vg01/lvol0 /tmp/new
```

13. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.
```shell
root@sysadm-fs:~# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
--2023-01-20 16:34:39--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 24488616 (23M) [application/octet-stream]
Saving to: ‘/tmp/new/test.gz’

/tmp/new/test.gz                    100%[=================================================================>]  23.35M  1.82MB/s    in 19s

2023-01-20 16:34:59 (1.24 MB/s) - ‘/tmp/new/test.gz’ saved [24488616/24488616]
```
14. Прикрепите вывод `lsblk`.
```shell
root@sysadm-fs:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0   62M  1 loop  /snap/core20/1611
loop2                       7:2    0 67.8M  1 loop  /snap/lxd/22753
loop3                       7:3    0 49.8M  1 loop  /snap/snapd/17950
loop4                       7:4    0 63.3M  1 loop  /snap/core20/1778
loop5                       7:5    0 91.9M  1 loop  /snap/lxd/24061
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    2G  0 part  /boot
└─sda3                      8:3    0   62G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0   31G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk
├─sdb1                      8:17   0    2G  0 part
│ └─md1                     9:1    0    2G  0 raid1
└─sdb2                      8:18   0  511M  0 part
  └─md0                     9:0    0 1017M  0 raid0
    └─vg01-lvol0          253:1    0  100M  0 lvm   /tmp/new
sdc                         8:32   0  2.5G  0 disk
├─sdc1                      8:33   0    2G  0 part
│ └─md1                     9:1    0    2G  0 raid1
└─sdc2                      8:34   0  511M  0 part
  └─md0                     9:0    0 1017M  0 raid0
    └─vg01-lvol0          253:1    0  100M  0 lvm   /tmp/new
```
15. Протестируйте целостность файла:

     ```bash
     root@vagrant:~# gzip -t /tmp/new/test.gz
     root@vagrant:~# echo $?
     0
     ```
```shell
root@sysadm-fs:~# gzip -t /tmp/new/test.gz
root@sysadm-fs:~# echo $?
0
```

16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.
```shell
root@sysadm-fs:~# pvmove /dev/md0 /dev/md1
  /dev/md0: Moved: 16.00%
  /dev/md0: Moved: 100.00%
root@sysadm-fs:~# lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0   62M  1 loop  /snap/core20/1611
loop2                       7:2    0 67.8M  1 loop  /snap/lxd/22753
loop3                       7:3    0 49.8M  1 loop  /snap/snapd/17950
loop4                       7:4    0 63.3M  1 loop  /snap/core20/1778
loop5                       7:5    0 91.9M  1 loop  /snap/lxd/24061
sda                         8:0    0   64G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    2G  0 part  /boot
└─sda3                      8:3    0   62G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0   31G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk
├─sdb1                      8:17   0    2G  0 part
│ └─md1                     9:1    0    2G  0 raid1
│   └─vg01-lvol0          253:1    0  100M  0 lvm   /tmp/new
└─sdb2                      8:18   0  511M  0 part
  └─md0                     9:0    0 1017M  0 raid0
sdc                         8:32   0  2.5G  0 disk
├─sdc1                      8:33   0    2G  0 part
│ └─md1                     9:1    0    2G  0 raid1
│   └─vg01-lvol0          253:1    0  100M  0 lvm   /tmp/new
└─sdc2                      8:34   0  511M  0 part
  └─md0                     9:0    0 1017M  0 raid0  
```
17. Сделайте `--fail` на устройство в вашем RAID1 md.
```shell
root@sysadm-fs:~# mdadm /dev/md1 --fail /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md1
```

18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.
```shell
[418347.574186] FS:  00007f31e06f6740 GS:  0000000000000000
[418347.576990] rcu: rcu_sched kthread starved for 391947 jiffies! g719097 f0x0 RCU_GP_WAIT_FQS(5) ->state=0x402 ->cpu=0
[418347.578816] rcu: RCU grace-period kthread stack dump:
[418347.579530] rcu_sched       I    0    11      2 0x80004000
[418347.579533] Call Trace:
[418347.579540]  __schedule+0x2e3/0x740
[418347.579542]  schedule+0x42/0xb0
[418347.579544]  schedule_timeout+0x8a/0x160
[418347.579547]  ? rcu_accelerate_cbs+0x65/0x190
[418347.579549]  ? __next_timer_interrupt+0xe0/0xe0
[418347.579551]  rcu_gp_kthread+0x48d/0x9a0
[418347.579553]  kthread+0x104/0x140
[418347.579554]  ? kfree_call_rcu+0x20/0x20
[418347.579556]  ? kthread_park+0x90/0x90
[418347.579557]  ret_from_fork+0x35/0x40
[442610.650685] 11:46:30.720076 timesync vgsvcTimeSyncWorker: Radical host time change: 1 994 109 000 000ns (HostNow=1 674 215 192 351 000 000 ns HostLast=1 674 213 198 242 000 000 ns)
[442610.650708] 11:46:30.720125 timesync vgsvcTimeSyncWorker: Radical guest time change: 1 993 897 103 000ns (GuestNow=1 674 215 190 720 062 000 ns GuestLast=1 674 213 196 822 959 000 ns fSetTimeLastLoop=false)
[459886.840461] EXT4-fs (dm-1): mounted filesystem with ordered data mode. Opts: (null)
[459886.840469] ext4 filesystem being mounted at /tmp/new supports timestamps until 2038 (0x7fffffff)
[460736.736313] md/raid1:md1: Disk failure on sdb1, disabling device.

# также это видно через mdstat (F и _U) 
root@sysadm-fs:~# cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md0 : active raid0 sdc2[1] sdb2[0]
      1041408 blocks super 1.2 512k chunks

md1 : active raid1 sdc1[1] sdb1[0](F)
      2094080 blocks super 1.2 [2/1] [_U]
```

19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

     ```bash
     root@vagrant:~# gzip -t /tmp/new/test.gz
     root@vagrant:~# echo $?
     0
     ```
```shell
root@sysadm-fs:~# gzip -t /tmp/new/test.gz
root@sysadm-fs:~# echo $?
0
```

20. Погасите тестовый хост, `vagrant destroy`.
Сделано
----
