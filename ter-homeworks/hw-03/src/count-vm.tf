#считываем данные об образе ОС
data "yandex_compute_image" "ubuntu-2004-lts" {
  family = "ubuntu-2004-lts"
}

#создаем 2 идентичные ВМ
resource "yandex_compute_instance" "webservers" {
  name        = "web-${count.index + 1}"
  platform_id = "standard-v1"
  
  count = 2

  resources {
    cores  = var.vm_web_resources.vm1.cores
    memory = var.vm_web_resources.vm1.memory
    core_fraction = var.vm_web_resources.vm1.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type = "network-hdd"
      size = 5
    }   
  }

  metadata = {
    ssh-keys = "ubuntu:${var.vms_ssh_root_key}"
  }

  scheduling_policy { preemptible = true }

  network_interface { 
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }
  allow_stopping_for_update = true
}

