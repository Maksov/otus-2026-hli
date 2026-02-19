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

data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

// Create Networks
resource "yandex_vpc_network" "ru-central1-d-servers-network" {
  name = "lb-otus-network"
}
// Create Networks

// Create Subnets
resource "yandex_vpc_subnet" "lb-otus-subnet-01" {
  name           = "lb-otus-subnet-01"
  zone           = var.zone
  network_id     = yandex_vpc_network.ru-central1-d-servers-network.id
  v4_cidr_blocks = ["10.160.0.0/24"]
}

// Create Subnets