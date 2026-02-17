terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = var.zone
}



resource "yandex_vpc_network" "otus-network" {
  name = "otus-network"
}

resource "yandex_vpc_subnet" "otus-hli-subnet" {
  name           = "otus-hli-subnet"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.otus-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}



