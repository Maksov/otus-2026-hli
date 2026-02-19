resource "local_file" "hosts" {
  filename = "inventory"
  depends_on = [
    yandex_compute_instance.fr-servers,
    yandex_compute_instance.lb-server,
    yandex_compute_instance.backend]
  content = templatefile("./hosts.tftpl", {
    nodes = yandex_compute_instance.fr-servers
    lb-server = yandex_compute_instance.lb-server
    backend = yandex_compute_instance.backend
  })
}


resource "null_resource" "ansible_provisioning" {
  depends_on = [
    yandex_compute_instance.fr-servers,
    yandex_compute_instance.lb-server,
    yandex_compute_instance.backend]
  provisioner "local-exec" {
    command = "ansible-playbook ./ansible/serverbase.yml"
    working_dir = path.module
    interpreter = ["bash", "-c"]
  }
}

