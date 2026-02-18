resource "local_file" "hosts" {
  filename = "inventory"
  depends_on = [yandex_compute_instance.pcs-servers]
  content = templatefile("./hosts.tftpl", {
    nodes = yandex_compute_instance.pcs-servers
    iscsi-server = yandex_compute_instance.iscsi-server
  })
}