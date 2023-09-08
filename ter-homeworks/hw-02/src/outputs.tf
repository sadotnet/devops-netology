# output "instance_ip_map" {
#   value = {
#     for instance in yandex_compute_instance.platform :
#     instance.na => instance.network_interface[0].access_config[0].nat_ip
#   }
# }
output "vm_external_ip_address" {
    # value = { first = "A", second = "B" }
    value = {ip_web = yandex_compute_instance.platform.network_interface[0].nat_ip_address, 
        ip_db = yandex_compute_instance.platform-db.network_interface[0].nat_ip_address}
}

