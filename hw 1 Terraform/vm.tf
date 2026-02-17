data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

resource "yandex_compute_disk" "boot-disk" {
  name     = "boot-disk-1"
  type     = var.disk_type
  zone     = var.zone
  size     = var.disk_size
  image_id = data.yandex_compute_image.ubuntu.image_id
}

resource "yandex_compute_instance" "vm-for-each" {
  
  platform_id    = "standard-v3"
  for_each   = {
    for index, vm in var.vm_resources_list:
    vm.vm_name => vm
  }
  
  
  resources {
    cores  = each.value.cpu
    memory = each.value.ram
    core_fraction = each.value.core_fraction
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.otus-hli-subnet.id
    nat       = var.nat
  }

  metadata = {
    ssh-keys = "ubuntu:${file("C:/Users/Maksim/.ssh/id_ed25519.pub")}"
  }
}
