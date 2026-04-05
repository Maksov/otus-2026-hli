
// Create VM
resource "yandex_compute_instance" "haproxy" {

  name                      = "haproxy"
  platform_id               = "standard-v3"
  hostname                  = "haproxy"
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
    subnet_id = yandex_vpc_subnet.patroni-otus-subnet-01.id
    nat       = true
  }
  
  metadata = {
    user-data = "${file("./cloud-init.yml")}"
  }
}
// Create VM