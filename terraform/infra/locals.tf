locals {
  worker_zones = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}

locals {
  subnet_zones = sort(keys(yandex_vpc_subnet.subnet))
}
