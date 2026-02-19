resource "local_file" "hosts" {
  filename = "inventory"
  depends_on = [yandex_compute_instance.pcs-servers]
  content = templatefile("./hosts.tftpl", {
    nodes = yandex_compute_instance.pcs-servers
    iscsi-server = yandex_compute_instance.iscsi-server
  })
}


resource "null_resource" "ansible_provisioning" {
  depends_on = [yandex_compute_instance.pcs-servers]
  provisioner "local-exec" {
    command = "ansible-playbook ./ansible/serverbase.yml"

    working_dir = path.module
    interpreter = ["bash", "-c"]
  }
}
