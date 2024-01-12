## Playbook

Устанавливает clickhouse,  vector и lighthouse

## Version and Branching
Версия 1

## Описание
- В inventory необходимо задать две группы хостов clickhouse и vector
- На сервера clickhouse:
- Скачивает clickhouse 
- Устанавливает  clickhouse и создает базу данных logs
- на серверах vector:
- Скачивает Vector
- Устанавливает vector
- Генерирует конфиг и копирует его в /etc/vector/vector.toml
- На сервера lighthouse:
- скачивает при помощи git статичный файл и поднимает его в nginx. 

### Prerequisite

- **Ansible 2.9+**

### Configure
в файле  `inventory/group_vars/clichouse` задайте требуюмую версию clichouse
В файле  inventory/prod.yml задается ansibhle_host для двух групп clichouse, vector, lighthouse
Замените ip1, ip2, ip3 на свои 
Также там задаетася ansible_user пользователь с которым ansible подключается на данный host

### Install
    # Deploy with ansible playbook - run the playbook as root
    ansible-playbook -i inventory/prod.yml site.yml
    
Вы можете поменять версию vector и файл для конфига в переменных 
    vector_version: "0.33.1"
    vector_config: "/etc/vector/vector.toml"    
Для lighthouse необходимо поправить следующие переменные:
    lighthouse_vcs: https://github.com/VKCOM/lighthouse.git
    lighthouse_location_dir: /opt/lighthouse

Для выбора места установки сайта и источник в git где он находится.