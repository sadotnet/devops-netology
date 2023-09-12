output "vpc_network_network_id" {
  value = yandex_vpc_network.network.id
}

output "vpc_subnet_subnet_name_id" {
  value = yandex_vpc_subnet.subnet_name.id
}
