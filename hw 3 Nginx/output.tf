// Outputs

output "external_ip_address_lb-server" {
  value = [
       yandex_compute_instance.lb-server[*].hostname, 
       yandex_compute_instance.lb-server[*].network_interface.0.nat_ip_address
       ]
}

output "internal_ip_address_lb-server" {
  value = [
    yandex_compute_instance.lb-server[*].hostname, 
    yandex_compute_instance.lb-server[*].network_interface.0.ip_address
    ]
}

output "external_ip_address_fr-servers" {
  value = [
    yandex_compute_instance.fr-servers[*].hostname, 
    yandex_compute_instance.fr-servers[*].network_interface.0.nat_ip_address
    ]
}

output "internal_ip_address_fr-servers" {
  value = [
    yandex_compute_instance.fr-servers[*].hostname, 
    yandex_compute_instance.fr-servers[*].network_interface.0.ip_address
    ]
}

output "external_ip_address_backend" {
  value = [
       yandex_compute_instance.backend[*].hostname, 
       yandex_compute_instance.backend[*].network_interface.0.nat_ip_address
       ]
}

output "internal_ip_address_backend" {
  value = [
    yandex_compute_instance.backend[*].hostname, 
    yandex_compute_instance.backend[*].network_interface.0.ip_address
    ]
}

// Outputs