resource "local_file" "hosts" {
  filename = "inventory"
  depends_on = [yandex_compute_instance.pg-servers, yandex_compute_instance.haproxy]
  content = templatefile("./hosts.tftpl", {
    nodes = yandex_compute_instance.pg-servers,
    haproxy = yandex_compute_instance.haproxy
  })
}


resource "null_resource" "ansible_provisioning" {
  depends_on = [yandex_compute_instance.pg-servers, yandex_compute_instance.haproxy]
  provisioner "local-exec" {
    command = "ansible-playbook ./ansible/serverbase.yml"
    working_dir = path.module
    interpreter = ["bash", "-c"]
  }
}

