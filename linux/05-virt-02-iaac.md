# Домашнее задание к занятию 2. «Применение принципов IaaC в работе с виртуальными машинами»

---
## Важно

Перед отправкой работы на проверку удаляйте неиспользуемые ресурсы.
Это нужно, чтобы не расходовать средства, полученные в результате использования промокода.

Подробные рекомендации [здесь](https://github.com/netology-code/virt-homeworks/blob/virt-11/r/README.md).

---

## Задача 1

- Опишите основные преимущества применения на практике IaaC-паттернов.
- Какой из принципов IaaC является основополагающим?

**Ответ**:
- Ускорение производства и вывода продукта на рынок
Пишем код, пушим в гит, написанный нами пейплайн собирает сборку, выполняет юнит тестирование, доставляет на стейдж , автоматически развёртывает. Имеется возможность залить на прод при нажатии кнопки и вызова нашего скрипта.

- Стабильность среды, устранение дрейфа конфигурации
Так как используется принцип идемпотентности, то наш скрипт развертывания создаёт одинаковую среду выполнения и серверов снежинок нет.

- Более быстрая и эффективная разработка
Разработчикам не надо думать о развёртывании ПО, их задача просто пушить код в гит и писать юнит тесты.

Главный принцип это идемпотентность т.е. свойство объекта или операции, при повторном выполнении которой мы получаем результат идентичный предыдущему и всем последующим выполнениям .



## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный — push или pull?

На мой взгляд всё таки pull метод, потому что если машина какая то в конкретный момент времени недоступна, и появляется позже, то ansible не сможет сконфигурировать её.


## Задача 3

Установите на личный компьютер:

- [VirtualBox](https://www.virtualbox.org/),
- [Vagrant](https://github.com/netology-code/devops-materials),
- [Terraform](https://github.com/netology-code/devops-materials/blob/master/README.md),
- Ansible.

```
#virtualbox
PS C:\Program Files\Oracle\VirtualBox> .\VBoxManage.exe --version
7.0.6r155176

#vagrant
vagrant --version
Vagrant 2.3.4

#terraform
Поставил по инструкции 
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli?in=terraform%2Faws-get-started

vagrant@server1:~$ terraform -version
Terraform v1.4.2
on linux_amd64

#ansible
vagrant@server1:~$ ansible --version
ansible [core 2.12.10]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/vagrant/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Nov 14 2022, 12:59:47) [GCC 9.4.0]
  jinja version = 2.10.1
  libyaml = True
```

## Задача 4 

Воспроизведите практическую часть лекции самостоятельно.

- Создайте виртуальную машину.
- Зайдите внутрь ВМ, убедитесь, что Docker установлен с помощью команды
```
docker ps,
```
Vagrantfile из лекции и код ansible находятся в [папке](https://github.com/netology-code/virt-homeworks/tree/virt-11/05-virt-02-iaac/src).

Примечание. Если Vagrant выдаёт ошибку:
```
URL: ["https://vagrantcloud.com/bento/ubuntu-20.04"]     
Error: The requested URL returned error: 404:
```

выполните следующие действия:

1. Скачайте с [сайта](https://app.vagrantup.com/bento/boxes/ubuntu-20.04) файл-образ "bento/ubuntu-20.04".
2. Добавьте его в список образов Vagrant: "vagrant box add bento/ubuntu-20.04 <путь к файлу>".

**Ответ**:

4.1 Подготовка Vagrantfile

Так как у меня windows машина, а не Mac то рецепты из видео затруднительно воспроизвести. 
Ставить ansible в windows не стал, так как официально такой вариант не поддерживается разработчиком ansible.
Поэтому использовал вариант с ansible_local для этого пришлось поменять Vagrantfile:

Чтобы ставил на гостя ansible после запуска ubuntu:

node.vm.provision "ansible_local"

Чтобы использовал мой ansible.cfg , а не дефолтный из /etc/ansible/ansible.cfg:

setup.config_file="./ansible.cfg" 

Полный рабочий Vagrantfile такой
```sh
ISO = "bento/ubuntu-20.04"
NET = "192.168.56."
DOMAIN = ".netology"
HOST_PREFIX = "server"
INVENTORY_PATH = "./inventory"

servers = [
  {
    :hostname => HOST_PREFIX + "1" + DOMAIN,
    :ip => NET + "11",
    :ssh_host => "20011",
    :ssh_vm => "22",
    :ram => 1024,
    :core => 1
  }
]

Vagrant.configure(2) do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: false
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = ISO
      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip: machine[:ip]
      node.vm.network :forwarded_port, guest: machine[:ssh_vm], host: machine[:ssh_host]
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
        vb.customize ["modifyvm", :id, "--cpus", machine[:core]]
        vb.name = machine[:hostname]
      end
      node.vm.provision "ansible_local" do |setup|
        setup.inventory_path = INVENTORY_PATH
        setup.config_file="./ansible.cfg"
        setup.playbook = "./playbook.yml"
        setup.become = true
        setup.extra_vars = { ansible_user: 'vagrant', ansible_password: 'vagrant' }
      end       
    end
  end
end
```

4.2. inventory для ansible
Поменял inventory:
```hosts
server1.netology ansible_host=127.0.0.1 ansible_port=22 ansible_user=vagrant ansible_password=vagrant
```Чтобы не прокидывать ключи, и порт на 22 , так как теперь ansible работает изнутри в гостевой ВМ.

4.3 Playbook такой же как в лекции, только убрал две таски по копированию ключей.

4.4 Процесс запуска ВМ и автоматической установки ansible , а затем docker с использованием ansible.

Лог:
```vagrant_up
PS C:\vagrant\netology_ubuntu> vagrant up
Bringing machine 'server1.netology' up with 'virtualbox' provider...
==> server1.netology: Importing base box 'bento/ubuntu-20.04'...
==> server1.netology: Matching MAC address for NAT networking...
==> server1.netology: Checking if box 'bento/ubuntu-20.04' version '202212.11.0' is up to date...
==> server1.netology: Setting the name of the VM: server1.netology
==> server1.netology: Clearing any previously set network interfaces...
==> server1.netology: Preparing network interfaces based on configuration...
    server1.netology: Adapter 1: nat
    server1.netology: Adapter 2: hostonly
==> server1.netology: Forwarding ports...
    server1.netology: 22 (guest) => 20011 (host) (adapter 1)
    server1.netology: 22 (guest) => 2222 (host) (adapter 1)
==> server1.netology: Running 'pre-boot' VM customizations...
==> server1.netology: Booting VM...
==> server1.netology: Waiting for machine to boot. This may take a few minutes...
    server1.netology: SSH address: 127.0.0.1:2222
    server1.netology: SSH username: vagrant
    server1.netology: SSH auth method: private key
    server1.netology:
    server1.netology: Vagrant insecure key detected. Vagrant will automatically replace
    server1.netology: this with a newly generated keypair for better security.
    server1.netology:
    server1.netology: Inserting generated public key within guest...
    server1.netology: Removing insecure key from the guest if it's present...
    server1.netology: Key inserted! Disconnecting and reconnecting using new SSH key...
==> server1.netology: Machine booted and ready!
==> server1.netology: Checking for guest additions in VM...
    server1.netology: The guest additions on this VM do not match the installed version of
    server1.netology: VirtualBox! In most cases this is fine, but in rare cases it can
    server1.netology: prevent things such as shared folders from working properly. If you see
    server1.netology: shared folder errors, please make sure the guest additions within the
    server1.netology: virtual machine match the version of VirtualBox you have installed on
    server1.netology: your host and reload your VM.
    server1.netology:
    server1.netology: Guest Additions Version: 6.1.40
    server1.netology: VirtualBox Version: 7.0
==> server1.netology: Setting hostname...
==> server1.netology: Configuring and enabling network interfaces...
==> server1.netology: Mounting shared folders...
    server1.netology: /vagrant => C:/vagrant/netology_ubuntu
==> server1.netology: Running provisioner: ansible_local...
    server1.netology: Installing Ansible...
    server1.netology: Running ansible-playbook...

PLAY [Playbook] ****************************************************************

TASK [Gathering Facts] *********************************************************
ok: [server1.netology]

TASK [Installing tools] ********************************************************
ok: [server1.netology] => (item=git)
ok: [server1.netology] => (item=curl)

TASK [Installing docker] *******************************************************
changed: [server1.netology]

TASK [Add the current user to docker group] ************************************
changed: [server1.netology]

PLAY RECAP *********************************************************************
server1.netology           : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

4.5 После этого захожу `vagrant ssh 

Результат docker установлен, задание выполнено:
```sh
vagrant@server1:~$ sudo docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
