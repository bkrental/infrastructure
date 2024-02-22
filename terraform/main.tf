resource "google_compute_network" "vpc" {
  name                    = "bkrental-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "public_subnet" {
  name          = "bkrental-public-subnet"
  network       = google_compute_network.vpc.self_link
  ip_cidr_range = "10.0.1.0/24"
}

resource "google_compute_instance" "dev_instance" {
  name         = "bkrental-dev-instance"
  machine_type = "e2-custom-medium-4864"
  network_interface {
    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.public_subnet.self_link
    access_config {
    }
  }
  boot_disk {
    auto_delete = true
    initialize_params {
      image = "ubuntu-2004-focal-v20240110"
      size  = 20
    }
  }

  metadata = {
    ssh-keys = "congdat:${file("./scripts/INFRA_SSH_KEY.pub")}"
  }
}

resource "google_compute_instance" "prod_instance" {
  name         = "bkrental-prod-instance"
  machine_type = "e2-custom-medium-4864"
  network_interface {
    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.public_subnet.self_link
    access_config {
    }
  }
  boot_disk {
    auto_delete = true
    initialize_params {
      image = "ubuntu-2004-focal-v20240110"
      size  = 20
    }
  }

  metadata = {
    ssh-keys = "congdat:${file("./scripts/INFRA_SSH_KEY.pub")}"
  }
}

resource "google_compute_instance" "load_balancer" {
  name         = "bkrental-load-balancer"
  machine_type = "e2-custom-medium-4864"
  network_interface {
    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.public_subnet.self_link
    access_config {
    }
  }
  boot_disk {
    auto_delete = true
    initialize_params {
      image = "ubuntu-2004-focal-v20240110"
      size  = 15
    }
  }

  metadata = {
    ssh-keys = "congdat:${file("./scripts/INFRA_SSH_KEY.pub")}"
  }
}


resource "google_compute_firewall" "public-fw" {
  name    = "bkrental-public-firewall"
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3000", "4000"]
  }

  source_ranges = ["0.0.0.0/0"]
}

output "dev_instance_ip" {
  value = google_compute_instance.dev_instance.network_interface.0.access_config.0.nat_ip
}

output "prod_instance_ip" {
  value = google_compute_instance.prod_instance.network_interface.0.access_config.0.nat_ip
}

output "load_balancer_ip" {
  value = google_compute_instance.load_balancer.network_interface.0.access_config.0.nat_ip
}
