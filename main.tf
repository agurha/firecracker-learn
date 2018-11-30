variable "token" {
  description = "packet token"
}

variable "projectid" {
  description = "packet project id"
}

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

resource "google_compute_instance" "demo" {
  name         = "${var.instance_name}"
  machine_type = "${var.machine_type}"
  zone         = "${var.gcp_zone}"

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
    inline = <<EOF
pushd /usr/local/bin
curl -o firecracker -L https://github.com/firecracker-microvm/firecracker/releases/download/v0.11.0/firecracker-v0.11.0
chmod +x firecracker
popd
git clone https://github.com/agurha/firecracker-learn /root/firecracker-learn
cd /root/firecracker-learn
cp conf/learnfirecracker.service /etc/systemd/system/
systemctl enable learnfirecracker.service
systemctl start learnfirecracker.service
EOF
  }
}