variable "vm_web_resources" {
    default = { 
        family = "ubuntu-2004-lts", 
        platform = "standard-v3", 
        cores = 2,
        memory = 1,
        core_fraction = 20,
    }
}



variable "vm_db_ubuntu_family" {
  type    = string
  default = "ubuntu-2004-lts"
}


variable "vm_db_platform_id" {
  type = string
  default = "standard-v3"
}

variable "vm_db_cores" {
  type = number
  default = 2
}

variable "vm_db_memory" {
  type = number
  default = 2
}

variable "vm_db_core_fraction" {
  type = number
  default = 20
}
