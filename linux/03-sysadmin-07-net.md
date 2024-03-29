# Домашнее задание к занятию "Компьютерные сети.Лекция 2"

### Цель задания

В результате выполнения этого задания вы:

1. Познакомитесь с инструментами настройки сети в Linux, агрегации нескольких сетевых интерфейсов, отладки их работы.
2. Примените знания о сетевых адресах на практике для проектирования сети.

### Инструменты/ дополнительные материалы, которые пригодятся для выполнения задания

1. [Калькулятор сетей online](https://calculator.net/ip-subnet-calculator.html).
2. Калькулятор сетей программа - ipcalc (`apt install ipcalc`), если есть графический интерфейс, то у программы калькулятора есть инженерный режим, там можно и сети считать.

------

## Задание

1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?
Ответ:
Кое что закрыл через X , так как работа на гитхаб в открытом доступе
```shell
vagrant@sysadm-fs:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:XX:cb:31 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 83114sec preferred_lft 83114sec
    inet6 fe80::a00:27ff:XXXX:XXXX/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:XX:XX:8f brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.3/24 brd 192.168.56.255 scope global dynamic eth1
       valid_lft 312sec preferred_lft 312sec
    inet6 fe80::a00:27ff:XXXX:XXXX/64 scope link
       valid_lft forever preferred_lft forever
```

Для Windows команда: 
```shell
ipconfig /all 
```


2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?
Проткоол lldp
Поставил пакет lldpd
```shell
apt install lldpd
```
Результат:
```shell
root@sysadm-fs:~# lldpctl
-------------------------------------------------------------------------------
LLDP neighbors:
```

3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.

Ответ:
VLAN 
Про VLan здесь: 
https://foofunc.com/how-to-configure-vlan-network-in-ubuntu/

Про netplan понравилось как здесь описано:
https://www.dmosk.ru/miniinstruktions.php?mini=network-netplan


```shell
sudo apt install vlan
modinfo 8021q
```
Вариант с несохраненной конфигурацией:
```shell
root@sysadm-fs:~# modinfo 8021q
filename:       /lib/modules/5.4.0-135-generic/kernel/net/8021q/8021q.ko
version:        1.8
license:        GPL
alias:          rtnl-link-vlan
srcversion:     634123A919317BAF16A45A8
depends:        mrp,garp
retpoline:      Y
intree:         Y
name:           8021q
vermagic:       5.4.0-135-generic SMP mod_unload modversions
sig_id:         PKCS#7
signer:         Build time autogenerated kernel key
sig_key:        0E:07:DA:A4:EC:90:87:F4:62:6E:57:ED:37:46:B6:BF:F7:BC:4C:72
sig_hashalgo:   sha512
signature:      41:F5:01:4B:1E:44:0F:B4:6A:FE:46:61:93:57:25:2B:BF:15:B9:AB:
                72:45:59:BB:9F:F4:2B:60:5B:66:1B:13:AE:87:D8:42:39:A9:11:55:
                C3:B5:88:C9:34:68:D4:68:EF:B6:65:A0:E1:0F:C4:0B:D9:56:4F:E6:


root@sysadm-fs:~# sudo ip link add link eth0 name eth0.100 type vlan id 100
root@sysadm-fs:~# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:59:XX:XX brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 83894sec preferred_lft 83894sec
    inet6 fe80::a00:27ff:XXXX:XXXX/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:a5:XX:XX brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.3/24 brd 192.168.56.255 scope global dynamic eth1
       valid_lft 491sec preferred_lft 491sec
    inet6 fe80::a00:27ff:fea5:b52/64 scope link
       valid_lft forever preferred_lft forever
4: eth0.100@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 08:00:27:59:XX:XX brd ff:ff:ff:ff:ff:ff

root@sysadm-fs:~# sudo ip addr add 192.168.100.2/24 dev eth0.100
```

Вариант с конфигом в netplan, поправил конфиг, вот такой получился:
```shell
root@sysadm-fs:/etc/netplan# cat 01-netcfg.yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
  vlans:
    eth0.100:
      id: 100
      link: eth0
      addresses: [192.168.100.2/24]
root@sysadm-fs:/etc/netplan# netplan generate
root@sysadm-fs:/etc/netplan# netplan apply
root@sysadm-fs:/etc/netplan# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:59:cb:31 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 86397sec preferred_lft 86397sec
    inet6 fe80::a00:27ff:fe59:cb31/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:a5:0b:52 brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.3/24 brd 192.168.56.255 scope global dynamic eth1
       valid_lft 597sec preferred_lft 597sec
    inet6 fe80::a00:27ff:fea5:b52/64 scope link
       valid_lft forever preferred_lft forever
4: eth0.100@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:59:cb:31 brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.2/24 brd 192.168.100.255 scope global eth0.100
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe59:cb31/64 scope link
       valid_lft forever preferred_lft forever
```


4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.

Ответ: 
агрегации (LAG): bonding и teaming.

Режимы в bonding
```shell
root@sysadm-fs:/etc/netplan# modinfo bonding |grep mode:Mode
parm:           mode:Mode of operation; 0 for balance-rr, 1 for active-backup, 2 for balance-xor, 3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, 6 for balance-alb (charp)
```

Для балансировки используются
```shell
parm:           mode:Mode of operation; 0 for balance-rr, 1 for active-backup, 2 for balance-xor, 3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, 6 for balance-alb (charp)
```

Конфиг bonds на отказоустойчивость пример
```shell
network:
    version: 2
    renderer: networkd
    ethernets:
        ens2f0: {}
        ens2f1: {}
    bonds:
        bond0:
            dhcp4: no
            interfaces:
            - ens2f0
            - ens2f1
            parameters:
                mode: active-backup
            addresses:
                - 192.168.122.195/24
            gateway4: 192.168.122.1
            mtu: 1500
            nameservers:
                addresses:
                    - 8.8.8.8
                    - 77.88.8.8
```


5. Сколько IP адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.
```shell
root@sysadm-fs:/etc/netplan# apt install ipcalc
root@sysadm-fs:/etc/netplan# ipcalc -b 10.10.10.0/29
Address:   10.10.10.0
Netmask:   255.255.255.248 = 29
Wildcard:  0.0.0.7
=>
Network:   10.10.10.0/29
HostMin:   10.10.10.1
HostMax:   10.10.10.6
Broadcast: 10.10.10.7
Hosts/Net: 6                     Class A, Private Internet
```
8 адресов = 6 для использования для хостов, 1 адрес сети и 1 широковещательный адрес. 
Сеть с маской /24 можно разбить 256 / 8 = 32 подсети с маской /29  

```shell
root@sysadm-fs:/etc/netplan# ipcalc -b 10.10.10.0/24
Address:   10.10.10.0
Netmask:   255.255.255.0 = 24
Wildcard:  0.0.0.255
=>
Network:   10.10.10.0/24
HostMin:   10.10.10.1
HostMax:   10.10.10.254
Broadcast: 10.10.10.255
Hosts/Net: 254                   Class A, Private Internet
```


6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.

Можно взять из CG-NAT
Технология CG-NAT (Carrier Grade Network Address Translation) дает провайдеру возможность заменить локальный IP-адрес пользователя на публичный в TCP/IP-сетях 
https://vasexperts.ru/blog/cg-nat/cg-nat-zachem-nuzhen-i-kak-nachat-polzovatsya/

```shell
root@sysadm-fs:/etc/netplan# ipcalc -b 100.64.0.0/10 -s 50
Address:   100.64.0.0
Netmask:   255.192.0.0 = 10
Wildcard:  0.63.255.255
=>
Network:   100.64.0.0/10
HostMin:   100.64.0.1
HostMax:   100.127.255.254
Broadcast: 100.127.255.255
Hosts/Net: 4194302               Class A

1. Requested size: 50 hosts
Netmask:   255.255.255.192 = 26
Network:   100.64.0.0/26
HostMin:   100.64.0.1
HostMax:   100.64.0.62
Broadcast: 100.64.0.63
Hosts/Net: 62                    Class A

Needed size:  64 addresses.
Used network: 100.64.0.0/26
Unused:
100.64.0.64/26
100.64.0.128/25
100.64.1.0/24
100.64.2.0/23
100.64.4.0/22
100.64.8.0/21
100.64.16.0/20
100.64.32.0/19
100.64.64.0/18
100.64.128.0/17
100.65.0.0/16
100.66.0.0/15
100.68.0.0/14
100.72.0.0/13
100.80.0.0/12
100.96.0.0/11
```
ipcalc подобрал маску /26 


7. Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?

Проверить таблицу можно так:

Linux: ip neigh
```shell
root@sysadm-fs:/etc/netplan# ip neigh
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE
192.168.56.2 dev eth1 lladdr 08:00:27:e5:93:9a STALE
10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 STALE
```
Windows: arp -a, замаксирова XXXX
```shell
arp -a

Интерфейс: 192.168.3.12 --- 0x7
  адрес в Интернете      Физический адрес      Тип
  192.168.3.1           XXXX     динамический
  192.168.4.1           XXXX     динамический
  224.0.0.22            XXXX     статический
  224.0.0.251           XXXX     статический
```
Очистить кеш так:
Linux: 
```shell
root@sysadm-fs:/etc/netplan# ip neigh flush all
```

Windows: arp -d * (Не хватило привелигий, не стал запускать под амдином) 
 
```shell
arp -d *
Сбой удаления записи таблицы ARP: Запрошенная операция требует повышения.
```

Удалить один IP так:
#delete a neighbour entry
ip neighbour delete 
