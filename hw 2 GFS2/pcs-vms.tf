
// Create VM
resource "yandex_compute_instance" "pcs-servers" {

  name                      = "pcs-${count.index + 1}"
  count                     =  3
  platform_id               = "standard-v3"
  hostname                  = "pcs-${count.index + 1}"
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
    nat       = true
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.pcs-servers-subnet-02.id
    nat        = false
    ip_address = "10.180.5.20${count.index + 1}"
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.iscsi-server-subnet-02.id
    nat        = false
    ip_address = "10.180.2.20${count.index + 1}"
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.iscsi-server-subnet-03.id
    nat        = false
    ip_address = "10.180.3.20${count.index + 1}"
  }

  
  metadata = {
    user-data = "${file("./cloud-init.yml")}"
  }

  depends_on = [
    yandex_compute_instance.iscsi-server
  ]
}