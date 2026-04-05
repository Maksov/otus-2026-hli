// Outputs

output "external_ip_address_haproxy" {
  value = [
       yandex_compute_instance.haproxy[*].hostname, 
       yandex_compute_instance.haproxy[*].network_interface.0.nat_ip_address
       ]
}

output "internal_ip_address_haproxy" {
  value = [
    yandex_compute_instance.haproxy[*].hostname, 
    yandex_compute_instance.haproxy[*].network_interface.0.ip_address
    ]
}

output "external_ip_address_pg-servers" {
  value = [
       yandex_compute_instance.pg-servers[*].hostname, 
       yandex_compute_instance.pg-servers[*].network_interface.0.nat_ip_address
       ]
}

output "internal_ip_address_pg-servers" {
  value = [
    yandex_compute_instance.pg-servers[*].hostname, 
    yandex_compute_instance.pg-servers[*].network_interface.0.ip_address
    ]
}
// Outputs