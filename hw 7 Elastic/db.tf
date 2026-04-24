// Create VM
resource "yandex_compute_instance" "db-server" {

  name                      = "db"
  platform_id               = "standard-v3"
  hostname                  = "db"
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
    subnet_id = yandex_vpc_subnet.pcs-servers-subnet-01.id
    nat       = false
    ip_address = "10.160.0.20"
  }



  metadata = {
    user-data = "${file("./cloud-init.yml")}"
  }
}
// Create VM