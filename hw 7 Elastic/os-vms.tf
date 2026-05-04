
// Create VM
resource "yandex_compute_instance" "os-servers" {

  name                      = "os-${count.index + 1}"
  count                     =  3
  platform_id               = "standard-v3"
  hostname                  = "os-${count.index + 1}"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id //Ubuntu 24.04
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.pcs-servers-subnet-01.id
    nat       = false
  }

  metadata = {
    user-data = "${file("./cloud-init.yml")}"
  }

  depends_on = [
    yandex_compute_instance.iscsi-server
  ]
}