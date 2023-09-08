#создаем 2 различные ВМ при помощи for_each
resource "yandex_compute_instance" "databases" {
  for_each = var.vm_web_resources
  name        = "data-${each.key}"
  platform_id = "standard-v1"
  

  resources {
    cores  = "${each.value.cores}"
    memory = "${each.value.memory}"
    core_fraction = "${each.value.core_fraction}"
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type = "network-hdd"
      size = 5
    }   
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy { preemptible = true }

  network_interface { 
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }
  allow_stopping_for_update = true
}

