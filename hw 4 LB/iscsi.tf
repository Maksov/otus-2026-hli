// Create secondary disks

resource "yandex_compute_disk" "iscsi-secondary-data-disk" {

  name = "iscsi-secondary-data-disk-01"
  type = "network-hdd"
  zone = var.zone
  size = "20"
}

// Create VM
resource "yandex_compute_instance" "iscsi-server" {

  name                      = "iscsi"
  platform_id               = "standard-v3"
  hostname                  = "iscsi"
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
    subnet_id = yandex_vpc_subnet.iscsi-server-subnet-01.id
    nat       = true
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.iscsi-server-subnet-02.id
    nat        = false
    ip_address = "10.180.2.204"
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.iscsi-server-subnet-03.id
    nat        = false
    ip_address = "10.180.3.204"
  }

  secondary_disk {
    disk_id = yandex_compute_disk.iscsi-secondary-data-disk.id
  }

  metadata = {
    user-data = "${file("./cloud-init.yml")}"
  }
}
// Create VM