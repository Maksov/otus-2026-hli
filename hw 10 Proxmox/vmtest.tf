resource "proxmox_vm_qemu" "alse" {
  vmid = 300 # id виртуальной машины в proxmox
  name        = "alse181" # ее название
  target_node = "cs47814" # название ноды
  clone       = "alse181-tmpl" # название шаблона из которого все разворачиваем
  full_clone  = true
  bios        = "seabios"
  agent       = 1 # установить qemu-guest-agent
  scsihw      = "virtio-scsi-single"
  os_type     = "linux"
  cpu {
        type    = "host"
        cores       = 4
        sockets     = 1      
  }
  memory      = 2048
  disks {

    ide {
            ide3 {
                cloudinit {
                    storage = "hdd-storage"
                }
            }
        }

    scsi {
      scsi0 {
        disk {
          size    = "3000M"
          storage = "hdd-storage"
          format  = "qcow2"
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr1"
  }

  # Setup the ip address using cloud-init.
  #  boot = "order=virtio0"
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=dhcp"
    nameserver = "8.8.8.8"
    ciuser = "admind"
    cipassword  = "P@ssw0rd86!" 

}