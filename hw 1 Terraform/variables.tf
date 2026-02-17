
 variable "vm_resources_list" {
    type          = list(object({
        vm_name       = string
        cpu           = number
        ram           = number
        disk          = number
        core_fraction = number
    }))
    default           = [
        {
        vm_name       = "otus-vm"
        cpu           = 2
        ram           = 2
        disk          = 1
        core_fraction = 20
        }
     ]
     description = "There's list if dict's with VM resources"
}

variable "zone" {
  type    = string
  default = "ru-central1-d"
}

variable "network" {
  type    = string
  default = "otus-hli-network"
}

variable "subnet" {
  type    = string
  default = "otus-network-sub"
}

variable "subnet_v4_cidr_blocks" {
  type    = list(string)
  default = ["192.168.10.0/16"]
}

variable "nat" {
  type    = bool
  default = true
}

variable "image_family" {
  type    = string
  default = "ubuntu-2404-lts"
}

variable "disk_size" {
  type    = number
  default = 20
}

variable "disk_type" {
  type    = string
  default = "network-hdd"
}




###cloud vars

variable "default_zone" {
  type        = string
  default     = "ru-central1-d"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "otus-network-sub"
  description = "VPC network&subnet name"
}

variable "vms_ssh_root_key" {
  type        = map(any)
  default     = {
    serial-port-enable = 1
    ssh-keys           = "~/.ssh/id_ed25519.pub"
  }
}