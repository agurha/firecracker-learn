variable "hostname" {
  default     = "firecracker-learn"
  description = "hostname"
}

# Configure the Packet Provider
provider "google" {
  credentials = "${file("account.json")}"
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}
resource "google_compute_firewall" "allow_ssh" {  
    name = "allow-ssh"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_http" {  
    name = "allow-http"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["http"]
}


resource "google_compute_instance" "demo" {
  name         = "${var.instance_name}"
  machine_type = "${var.machine_type}"
  zone         = "${var.gcp_zone}"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("~/.ssh/google_compute_engine")}"
      agent       = false
    }

    inline = [
      "sudo curl -sSL https://get.docker.com/ | sh",
      "sudo usermod -aG docker `echo $USER`",
      "sudo docker run -d -p 80:80 nginx",
      "sudo apt-get update",
      "sudo apt-get dist-upgrade -y",
      "sudo apt-get install -y language-pack-en sysstat vim htop git",
      "pushd /usr/local/bin",
      "sudo curl -o firecracker -L https://github.com/firecracker-microvm/firecracker/releases/download/v0.11.0/firecracker-v0.11.0",
      "sudo chmod +x firecracker",
      "sudo popd",
      "sudo git clone https://github.com/agurha/firecracker-learn /root/firecracker-learn",
      "cd /root/firecracker-learn",
      "cp conf/learnfirecracker.service /etc/systemd/system/",
      "sudo systemctl enable learnfirecracker.service",
      "sudo systemctl start learnfirecracker.service"
    ]
  }

  # Ensure firewall rule is provisioned before server, so that SSH doesn't fail.
  depends_on = ["google_compute_firewall.allow_ssh", "google_compute_firewall.allow_http"]

  metadata {
    ssh-keys = "USERNAME:${file("~/.ssh/google_compute_engine.pub")}"
  }

}