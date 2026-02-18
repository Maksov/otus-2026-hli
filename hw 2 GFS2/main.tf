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
resource "yandex_vpc_network" "ru-central1-d-servers-network-01" {
  name = "gfs2-otus-network-01"
}
// Create Networks

// Create Subnets
resource "yandex_vpc_subnet" "pcs-servers-subnet-01" {
  name           = "pcs-servers-subnet-01"
  zone           = var.zone
  network_id     = yandex_vpc_network.ru-central1-d-servers-network-01.id
  v4_cidr_blocks = ["10.160.0.0/24"]
}

resource "yandex_vpc_subnet" "pcs-servers-subnet-02" {
  name           = "pcs-servers-subnet-02"
  zone           = var.zone
  network_id     = yandex_vpc_network.ru-central1-d-servers-network-01.id
  v4_cidr_blocks = ["10.180.5.0/24"]
}

resource "yandex_vpc_subnet" "iscsi-server-subnet-01" {
  name           = "iscsi-servers-subnet-01"
  zone           = var.zone
  network_id     = yandex_vpc_network.ru-central1-d-servers-network-01.id
  v4_cidr_blocks = ["10.180.1.0/24"]
}

resource "yandex_vpc_subnet" "iscsi-server-subnet-02" {
  name           = "iscsi-servers-subnet-02"
  zone           = var.zone
  network_id     = yandex_vpc_network.ru-central1-d-servers-network-01.id
  v4_cidr_blocks = ["10.180.2.0/24"]
}

resource "yandex_vpc_subnet" "iscsi-server-subnet-03" {
  name           = "iscsi-servers-subnet-03"
  zone           = var.zone
  network_id     = yandex_vpc_network.ru-central1-d-servers-network-01.id
  v4_cidr_blocks = ["10.180.3.0/24"]
}

// Create Subnets