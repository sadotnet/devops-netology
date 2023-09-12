locals {
  ssh_pub_key = "${file("~/.ssh/id_ed25519.pub")}"
  username = "ubuntu"
}

