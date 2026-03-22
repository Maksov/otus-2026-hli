resource "local_file" "hosts" {
  filename = "inventory"
  depends_on = [yandex_compute_instance.pxс-servers]
  content = templatefile("./hosts.tftpl", {
    nodes = yandex_compute_instance.pxs-servers
  })
}


resource "null_resource" "ansible_provisioning" {
  depends_on = [yandex_compute_instance.pxс-servers]
  provisioner "local-exec" {
    command = "ansible-playbook ./ansible/serverbase.yml"
    working_dir = path.module
    interpreter = ["bash", "-c"]
  }
}

