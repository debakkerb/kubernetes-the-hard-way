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

output "project_id" {
  value = module.project.project_id
}

output "project_name" {
  value = module.project.project_name
}

output "workers" {
  sensitive = true
  value     = google_compute_instance.workers
}

output "controllers" {
  sensitive = true
  value     = google_compute_instance.controllers
}

output "controller_instance_names" {
  value = local.controller_instance_names
}

output "worker_instance_names" {
  value = local.worker_instance_names
}

output "controller_instance_ip_addresses" {
  value = local.controller_instance_ip_addresses
}

output "worker_instance_ip_addresses" {
  value = local.worker_instance_ip_addresses
}

output "api_server_endpoint" {
  value = var.create_public_ip_address ? google_compute_address.kube_api_server_endpoint.0.address : ""
}

output "region" {
  value = var.region
}

output "zone" {
  value = var.zone
}
