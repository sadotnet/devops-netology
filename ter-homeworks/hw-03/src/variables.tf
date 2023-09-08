###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "vms_ssh_root_key" {
  type        = string
  # default     = "AAAAC3NzaC1lZDI1NTE5AAAAIMMlKIdKZOQH+/QtX18Y21Q2dsjmvoxr2jyiCGw3yN3B" - incorrect
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMMlKIdKZOQH+/QtX18Y21Q2dsjmvoxr2jyiCGw3yN3B vent"
  description = "ssh-keygen -t ed25519"
}


variable "vm_web_resources" {
  default = {
    vm1 = {
      cores = 2,
      memory = 1,
      core_fraction = 20,
    },
    vm2 = {
      cores = 4,
      memory = 2,
      core_fraction = 5,
    },
  }
}
