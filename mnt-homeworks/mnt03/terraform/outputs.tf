output "vm_external_ip_address" {
    value = {
        ip_vector = yandex_compute_instance.vector_platform.network_interface[0].nat_ip_address, 
        ip_clickhouse = yandex_compute_instance.clickhouse-platform.network_interface[0].nat_ip_address
        ip_lighthouse = yandex_compute_instance.lighthouse-platform.network_interface[0].nat_ip_address
    }
}