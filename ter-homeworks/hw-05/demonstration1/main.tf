terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.13"
    }
     template = {
      source  = "hashicorp/template"
      version = ">= 2.0.0"
    }

  }
  required_version = ">=0.13"


  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket = "state-lock-db"
    region = "ru-central1"
    key = "terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    dynamodb_endpoint = "https://docapi.serverless.yandexcloud.net/ru-central1/b1grng0r9tbanc9u316l/etn8aa5nk6vfus591eoi"
    dynamodb_table = "state-lock-table"
  }

# # Рабочий пример 
#   backend "s3" {
#     endpoint = "storage.yandexcloud.net"
#     bucket = "tfstate-develop-my"
#     region = "ru-central1"
#     key = "terraform.tfstate"
#     skip_region_validation      = true
#     skip_credentials_validation = true
#   }


}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}


#создаем облачную сеть
resource "yandex_vpc_network" "develop" {
  name = "develop"
}

#создаем подсеть
resource "yandex_vpc_subnet" "develop" {
  name           = "develop-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}


module "test-vm" {
  source          = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=dev"
  env_name        = "develop"
  network_id      = yandex_vpc_network.develop.id
  subnet_zones    = ["ru-central1-a"]
  subnet_ids      = [ yandex_vpc_subnet.develop.id ]
  instance_name   = "web"
  instance_count  = 2
  image_family    = "ubuntu-2004-lts"
  public_ip       = true
  
  metadata = {
      user-data          = data.template_file.cloudinit.rendered #Для демонстрации №3
      serial-port-enable = 1
      disable-serial-console = "false"
      
  }
}

#Пример передачи cloud-config в ВМ для демонстрации №3
data "template_file" "cloudinit" {
   template = file("./cloud-init.yml")

}


#terraform init -backend-config="access_key=<s3_access_key>" -backend-config="secret_key=<s3_secret_key>"


