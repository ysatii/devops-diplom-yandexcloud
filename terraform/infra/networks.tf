resource "yandex_vpc_network" "k8s" {
  name = "k8s-net"
}

resource "yandex_vpc_subnet" "k8s" {
  name           = "k8s-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.k8s.id
  v4_cidr_blocks = [var.network_cidr]
}
