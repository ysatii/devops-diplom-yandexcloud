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
 
