variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "env_name" {
  type        = string
  default     = "develop"
  description = "Environment name"
}

variable "subnet_prefix" {
  type        = string
  default     = "sbnt"
  description = "Subnet prefix"
}

