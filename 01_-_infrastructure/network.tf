/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_compute_network" "default" {
  project                 = module.project.project_id
  name                    = format("%s-%s", var.prefix, var.network_name)
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  project                  = module.project.project_id
  name                     = format("%s-%s", var.prefix, var.subnet_name)
  ip_cidr_range            = var.subnet_cidr_block
  network                  = google_compute_network.default.name
  region                   = var.region
  private_ip_google_access = true
}

resource "google_compute_firewall" "fw_iap_access" {
  project = module.project.project_id
  name    = format("%s-%s", var.prefix, "fw-iap-access")
  network = google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [
    "35.235.240.0/20"
  ]

  target_tags = ["iap-access"]
}

resource "google_compute_firewall" "lb_health_check" {
  project   = module.project.project_id
  name      = format("%s-%s", var.prefix, "fw-lb-hc")
  network   = google_compute_network.default.name
  direction = "INGRESS"

  source_ranges = [
    "209.85.152.0/22",
    "209.85.204.0/22",
    "35.191.0.0/16"
  ]

  allow {
    protocol = "tcp"
  }
}

resource "google_compute_address" "kube_api_server_endpoint" {
  project      = module.project.project_id
  name         = format("%s-%s", var.prefix, "control-plane-endpoint")
  address_type = "EXTERNAL"
  region       = var.region
}

resource "google_compute_router" "egress_traffic_router" {
  count   = var.enable_egress_traffic ? 1 : 0
  project = module.project.project_id
  name    = format("%s-%s", var.prefix, "egress-traffic-rtr")
  network = google_compute_network.default.name
  region  = var.region

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "egress_traffic_nat" {
  count                              = var.enable_egress_traffic ? 1 : 0
  project                            = module.project.project_id
  name                               = format("%s-%s", var.prefix, "egress-traffic-nat")
  nat_ip_allocate_option             = "AUTO_ONLY"
  router                             = google_compute_router.egress_traffic_router.0.name
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  region                             = var.region

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_route" "egress_traffic_route" {
  count            = var.enable_egress_traffic ? 1 : 0
  project          = module.project.project_id
  name             = format("%s-%s", var.prefix, "internet-access")
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.default.name
  next_hop_gateway = "default-internet-gateway"
}

