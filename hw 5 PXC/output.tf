// Outputs

output "external_ip_address_pxc-servers" {
  value = [
       yandex_compute_instance.pxc-servers[*].hostname, 
       yandex_compute_instance.pxc-servers[*].network_interface.0.nat_ip_address
       ]
}

output "internal_ip_address_pxc-servers" {
  value = [
    yandex_compute_instance.pxc-servers[*].hostname, 
    yandex_compute_instance.pxc-servers[*].network_interface.0.ip_address
    ]
}
// Outputs