
// Create VM
resource "yandex_compute_instance" "pxc-servers" {

  name                      = "pxc-${count.index + 1}"
  count                     =  3
  platform_id               = "standard-v3"
  hostname                  = "pxc-${count.index + 1}"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id //Ubuntu 24.04
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.pxc-otus-subnet-01.id
    nat       = true
    ip_address = "10.160.0.10${count.index}"
  }

  metadata = {
    user-data = "${file("./cloud-init.yml")}"
  }

}