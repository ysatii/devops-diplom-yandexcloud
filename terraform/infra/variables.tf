variable "token" {
  type      = string
  sensitive = true
}

variable "cloud_id" {
  default = "b1ggavufohr5p1bfj10e"
}

variable "folder_id" {
  default = "b1g0hcgpsog92sjluneq"
}

# Бакет  
variable "bucket_name" {
  type    = string
  default = "bucket-terraform-save1"
}

variable "zone" {
  default = "ru-central1-a"
}

variable "default_zone" {
  default     = "ru-central1-a"
}

variable "network_cidr" {
  type = string
  default = "10.240.0.0/24"
}

variable "ssh_user" {
  type = string
  default = "ubuntu" 
}

variable "image_family" {
  type = string 
  default = "ubuntu-2204-lts" 
}

variable "master_count" {
  type = number
  default = 1 
}

variable "worker_count" {
  type = number
  default = 2 
}

# ресурсы ВМ (можно менять)
variable "master_cores" {
  type = number
  default = 4 
}

variable "master_memory" {
  type = number
  default = 4 
}

variable "worker_cores" {
  type = number
  default = 4
}

variable "worker_memory" {
  type = number
  default = 4
}

variable "disk_size_gb" {
  type = number
  default = 30 
}

# прерываемые (recommended для worker)
variable "workers_preemptible" {
  type = bool 
  default = true 
}

variable "subnets" {
  type = list(object({
    zone = string
    cidr = string
  }))
  default = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", cidr = "10.0.2.0/24" },
    { zone = "ru-central1-d", cidr = "10.0.3.0/24" },
  ]
}