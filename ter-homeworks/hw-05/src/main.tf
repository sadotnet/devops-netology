resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}


variable "foobar" {
  type        = string
  description = "An example variable"
  
  validation {
    condition     = length(var.foobar) >= 5 && length(var.foobar) <= 10
    error_message = "The length of var.foobar must be between 5 and 10 characters."
  }
}


