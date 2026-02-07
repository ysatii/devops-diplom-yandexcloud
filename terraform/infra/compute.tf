data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}



resource "yandex_compute_instance" "master" {
  count = var.master_count

  name        = "k8s-master-${count.index + 1}"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = var.master_cores
    memory = var.master_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.disk_size_gb
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.k8s.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.k8s.id]
  }

  metadata = {
  user-data = file("${path.module}/meta.txt")
  }

}

resource "yandex_compute_instance" "worker" {
  count = var.worker_count

  name        = "k8s-worker-${count.index + 1}"
  platform_id = "standard-v3"
  zone        = var.zone

  scheduling_policy {
    preemptible = var.workers_preemptible
  }

  resources {
    cores  = var.worker_cores
    memory = var.worker_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.disk_size_gb
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.k8s.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.k8s.id]
  }

  metadata = {
  user-data = file("${path.module}/meta.txt")
  }

}
