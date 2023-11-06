resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}

data "yandex_compute_image" "ubuntu" {
  family =  var.vm_web_resources.family
}

data "yandex_compute_image" "centos" {
  family =  var.vm_db_family
}

resource "yandex_compute_instance" "vector_platform" {
  name        =  local.vm_vector
  platform_id = var.vm_web_resources.platform
  resources {
    cores         = var.vm_web_resources.cores
    memory        = var.vm_web_resources.memory
    core_fraction = var.vm_web_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = 5

    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

  # boot_disk {
  #   initialize_params {
  #     image_id = data.yandex_compute_image.ubuntu.image_id
  #     type = "network-hdd"
  #   }   
  # }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.virtual_disk[*]
    content {
      device_name = "disk-${secondary_disk.key+1}"
      disk_id     = secondary_disk.value.id
    }
  }


}

resource "yandex_compute_instance" "clickhouse-platform" {
  name        =  local.vm_clickhouse
  platform_id = var.vm_db_platform_id
  resources {
    cores         = var.vm_db_cores
    memory        = var.vm_db_memory
    core_fraction = var.vm_db_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.centos.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}

resource "yandex_compute_instance" "lighthouse-platform" {
  name        =  local.vm_lighthouse
  platform_id = var.vm_web_resources.platform
  resources {
    cores         = var.vm_web_resources.cores
    memory        = var.vm_web_resources.memory
    core_fraction = var.vm_web_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = 5
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

  # boot_disk {
  #   initialize_params {
  #     image_id = data.yandex_compute_image.ubuntu.image_id
  #     type = "network-hdd"
  #   }   
  # }
}