resource "yandex_vpc_network" "k8s" {
  name = "k8s-net"
}

resource "yandex_vpc_subnet" "subnet" {
  for_each = { for s in var.subnets : s.zone => s }

  name           = "subnet-${each.value.zone}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.k8s.id
  v4_cidr_blocks = [each.value.cidr]
}
