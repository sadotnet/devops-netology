resource "yandex_compute_disk" "virtual_disk" {
  count         = 3
  name          = "my-virtual-disk-${count.index}"
  size          = 1
}

output "disk_ids" {
  value = yandex_compute_disk.virtual_disk[*].id
}

resource "yandex_compute_instance" "storage" {
  name        = "storage"
  platform_id = "standard-v1"
  
  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
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

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.virtual_disk[*]
    content {
      device_name = "disk-${secondary_disk.key+1}"
      disk_id     = secondary_disk.value.id
    }
  }
}
