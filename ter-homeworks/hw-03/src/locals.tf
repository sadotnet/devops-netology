locals {
  ssh_pub_key = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
}