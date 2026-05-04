resource "local_file" "hosts" {
  filename = "inventory"
  depends_on = [yandex_compute_instance.pcs-servers]
  content = templatefile("./hosts.tftpl", {
    nodes = yandex_compute_instance.pcs-servers
    iscsi-server = yandex_compute_instance.iscsi-server
    db-server = yandex_compute_instance.db-server
    jump-server = yandex_compute_instance.jump-server
    os-servers = yandex_compute_instance.os-servers
  })
}


resource "null_resource" "ansible_provisioning" {
  depends_on = [yandex_compute_instance.pcs-servers, yandex_compute_instance.os-servers]
  provisioner "local-exec" {
    command = "ansible-playbook ./ansible/serverbase.yml --extra-vars '{\"admin_password\":\"admin@Otus1234\", \"kibanaserver_password\":\"kibana@Otus1234\", \"logstash_password\":\"logstash@Otus1234\"}'"
    working_dir = path.module
    interpreter = ["bash", "-c"]
  }
}

