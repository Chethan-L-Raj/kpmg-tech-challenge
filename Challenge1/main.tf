provider "google" {
  credentials = "chet-kpmg-dev-npe-786944b67e77.json"
  project     = var.project_id
  region      = var.region
}

## set upi VPC network
resource "google_compute_network" "network_kpmg" {
  name = "kpmg-network"
}

## Creating a custom subnet
resource "google_compute_subnetwork" "subnet_kpmg" {
  name          = "kpmg-subnet"
  region        = var.region
  network       = google_compute_network.network_kpmg.self_link
  ip_cidr_range = "10.0.0.0/24"
}

## Setting up firewall rules
resource "google_compute_firewall" "http_firewall" {
  name    = "http-firewall"
  network = google_compute_network.network_kpmg.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

## creating VM Instance Group
resource "google_compute_instance_group" "kpmg_instance_group" {
  name      = "kpmg-instance-group"
  zone      = var.zone
  instances = [google_compute_instance.kpmg_vm.id]
  named_port {
    name = "http"
    port = "8080"
  }

  named_port {
    name = "https"
    port = "8443"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# defining disk to be used
/* data "google_compute_image" "debian_image" {
  family  = "debian-12"
  project = var.project_id
} */

# compute instance creation
resource "google_compute_instance" "kpmg_vm" {
  name         = "kpmg-vm"
  machine_type = "e2-micro"
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }
  metadata = {
    key1 = "value1"
    bread = "butter"
    elephant = "animal"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_kpmg.self_link
    access_config {
    }
  }
}

# enabling backend services to perform health checks on instances belonging to instance group
resource "google_compute_backend_service" "backend_service" {
  name      = "backend-service"
  port_name = "https"
  protocol  = "HTTPS"

  backend {
    group = google_compute_instance_group.kpmg_instance_group.id
  }

  health_checks = [
    google_compute_https_health_check.staging_health.id,
  ]
}

resource "google_compute_https_health_check" "staging_health" {
  name         = "staging-health"
  request_path = "/health_check"
}

resource "google_sql_database_instance" "kpmg_db_instance" {
  name             = "kpmg-db-instance"
  database_version = "MYSQL_5_7"
  region           = var.region
  settings {
    tier = "db-n1-standard-1"
  }
}

resource "google_sql_database" "application_database" {
  name     = "application-x-database"
  instance = google_sql_database_instance.kpmg_db_instance.name
}

resource "google_compute_resource_policy" "daily_backup" {
  name   = "every-day-4am"
  region = var.region
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }
  }
}

output "load_balancer_ip" {
  value = google_compute_instance_group.kpmg_instance_group.self_link
}