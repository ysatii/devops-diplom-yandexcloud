locals {
  masters = [
    for i in yandex_compute_instance.master : {
      public_ip  = i.network_interface[0].nat_ip_address
      private_ip = i.network_interface[0].ip_address
    }
  ]

  workers = [
    for i in yandex_compute_instance.worker : {
      public_ip  = i.network_interface[0].nat_ip_address
      private_ip = i.network_interface[0].ip_address
    }
  ]
}

resource "local_file" "kubespray_inventory" {
  filename = "${path.module}/../kubespray/inventory/my-k8s-cluster/hosts.yml"

  content = templatefile("${path.module}/inventory.tftpl", {
    masters      = local.masters
    workers      = local.workers
    ansible_user = "lamer"
  })
}
