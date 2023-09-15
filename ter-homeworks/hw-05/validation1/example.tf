# variable "mynum" {
#   type        = number
#   default     = 1

#   validation {
#     condition     = var.mynum >= 10
#     error_message = "Accepted values: >= 10."
#   }
# }
variable "ip_address" {
  description = "ip-адрес"
  type        = string
  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.ip_address))
    error_message = "Неверный формат ip-адреса"
  }
  default = "1920.168.0.1"
}

variable "ip_addresses" {
  description = "список ip-адресов"
  type        = list(string)
  validation {
    condition     = length(var.ip_addresses) == length([for ip in var.ip_addresses : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))])
    error_message = "Один или несколько ip-адресов в списке неверного формата"
  }
  default = ["192.168.0.1", "1.1.1.1", "127.0.0.1"]
#   default = ["192.168.0.1", "1.1.1.1", "1270.0.0.1"]
}


