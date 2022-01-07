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