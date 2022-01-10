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

resource "google_compute_http_health_check" "health_check" {
  project      = module.project.project_id
  name         = format("%s-%s", var.prefix, "control-plane")
  description  = "Health Check for the control plane."
  host         = "kubernetes.default.svc.cluster.local"
  request_path = "/healthz"
}

resource "google_compute_target_pool" "control_plane_target_pool" {
  project   = module.project.project_id
  name      = format("%s-%s", var.prefix, "control-plane-pool")
  instances = local.controller_instances_self_links
  region    = var.region

  health_checks = [
    google_compute_http_health_check.health_check.name
  ]
}

resource "google_compute_forwarding_rule" "control_plane_forwarding_rule" {
  project               = module.project.project_id
  name                  = format("%s-%s", var.prefix, "control-plane-fwd-rule")
  ip_address            = google_compute_address.kube_api_server_endpoint.0.address
  port_range            = "6443"
  region                = var.region
  target                = google_compute_target_pool.control_plane_target_pool.self_link
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "tcp"
}