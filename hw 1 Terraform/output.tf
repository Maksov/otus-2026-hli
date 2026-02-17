output "internal_ip_address_vm" {

  value = [
  for i in yandex_compute_instance.vm-for-each :
    {
        ip_address = i.network_interface.0.ip_address
    }
  ]
}

output "external_ip_address_vm" {
value = [
  for i in yandex_compute_instance.vm-for-each :
    {
        nat_ip_address = i.network_interface.0.nat_ip_address
    }
  ]
}