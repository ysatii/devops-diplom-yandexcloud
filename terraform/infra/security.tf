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
 
  ingress {
    protocol       = "TCP"
    description    = "NodePort 30080 app"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30080
    to_port        = 30080
  }

  ingress {
    protocol       = "TCP"
    description    = "NodePort 30090 grafana"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30090
    to_port        = 30090
  }


  # Внутрикластерное общение (всё внутри подсети)
  ingress {
    protocol       = "ANY"
    description    = "Internal"
    v4_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
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
