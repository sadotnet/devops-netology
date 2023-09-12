module "vpc" {
  source    = "./vpc"
  env_name  = var.vpc_name
  zone      = var.default_zone
  default_cidr = var.default_cidr
}

# resource "yandex_vpc_network" "develop" {
#   name = var.vpc_name
# }

# resource "yandex_vpc_subnet" "develop" {
#   name           = var.vpc_name
#   zone           = var.default_zone
#   network_id     = yandex_vpc_network.develop.id
#   v4_cidr_blocks = var.default_cidr
# }

module "test-vm" {
  source          = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name        = "develop"
  network_id      = module.vpc.vpc_network_network_id
  subnet_zones    = ["ru-central1-a"]
  subnet_ids      = [ module.vpc.vpc_subnet_subnet_name_id]
  instance_name   = "web"
  instance_count  = 2
  image_family    = "ubuntu-2004-lts"
  public_ip       = true
  
  metadata = {
      user-data          = data.template_file.cloudinit.rendered #Для демонстрации №3
      serial-port-enable = 1
  }

}

#Пример передачи cloud-config в ВМ для демонстрации №3
data "template_file" "cloudinit" {
 template = file("./cloud-init.yml")
 vars = {
    username           = local.username
    ssh_public_key     = local.ssh_pub_key
    packages = jsonencode(var.packages)
  }
}
