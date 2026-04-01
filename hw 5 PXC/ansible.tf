resource "local_file" "hosts" {
  filename = "inventory"
  depends_on = [yandex_compute_instance.pxc-servers]
  content = templatefile("./hosts.tftpl", {
    nodes = yandex_compute_instance.pxc-servers
  })
}


resource "null_resource" "ansible_provisioning" {
  depends_on = [yandex_compute_instance.pxc-servers]
  provisioner "local-exec" {
    command = "ansible-playbook ./ansible/serverbase.yml"
    working_dir = path.module
    interpreter = ["bash", "-c"]
  }
}

