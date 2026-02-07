resource "yandex_vpc_security_group" "k8s" {
  name       = "k8s-sg"
  network_id = yandex_vpc_network.k8s.id

  # SSH (лучше потом ограничить своим IP)
  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  # Kubernetes API (для доступа kubectl/ansible)
  ingress {
    protocol       = "TCP"
    description    = "K8s API"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }

  # NodePort (если будешь использовать)
  ingress {
    protocol       = "TCP"
    description    = "NodePort range"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 32767
  }

  # Внутрикластерное общение (всё внутри подсети)
  ingress {
    protocol       = "ANY"
    description    = "Internal"
    v4_cidr_blocks = [var.network_cidr]
    from_port      = 0
    to_port        = 65535
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
