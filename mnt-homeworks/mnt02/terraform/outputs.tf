output "vm_external_ip_address" {
    value = {ip_web = yandex_compute_instance.platform.network_interface[0].nat_ip_address, 
        ip_db = yandex_compute_instance.platform-db.network_interface[0].nat_ip_address}
}