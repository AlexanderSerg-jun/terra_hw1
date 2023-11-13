terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

  required_version = ">= 0.13"
}
provider "yandex" {
  token     = var.token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone = var.zone
}
resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "fd808e721rc1vt7jkd0o"

    }
  }
  network_interface {

    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }
  metadata = {
    user-data = "${file("~/first_ter/meta.yml")}"
  }

  connection {
    type        = "ssh"
    user        = "alex"
    agent       = true
    
    host        = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
  }
  provisioner "remote-exec" {
    inline = ["echo 'Start'"]

  }
  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.network_interface.0.nat_ip_address},' --private-key ~/.ssh/id_25519 --user alex provision.yml"
  }
}
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}
resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = var.zone
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

