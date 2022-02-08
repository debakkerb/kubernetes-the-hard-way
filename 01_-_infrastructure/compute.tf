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

locals {
  controller_instances_self_links = var.num_controllers != 0 ? var.use_kubeadm ? [google_compute_instance.controllers.0.self_link] : [for k, v in google_compute_instance.controllers : v.self_link] : []

  controller_instance_names = [
    for k, v in google_compute_instance.controllers : v.name
  ]

  worker_instance_names = [
    for k, v in google_compute_instance.workers : v.name
  ]

  controller_instance_ip_addresses = flatten([
    for instance in google_compute_instance.controllers : [
      for network in instance.network_interface : [
        network.network_ip
      ]
    ]
  ])

  worker_instance_ip_addresses = flatten([
    for instance in google_compute_instance.workers : [
      for network in instance.network_interface : [
        network.network_ip
      ]
    ]
  ])

  controller_project_iam_permissions = [
    "roles/storage.admin",
    "roles/logging.logWriter",
    "roles/compute.instanceAdmin.v1"
  ]
}

resource "google_service_account" "worker_identity" {
  project      = module.project.project_id
  account_id   = format("%s-%s", var.prefix, "worker-id")
  description  = "Worker Identity"
  display_name = "Worker Identity"
}

resource "google_service_account" "controller_identity" {
  project     = module.project.project_id
  account_id  = format("%s-%s", var.prefix, "controller-id")
  description = "Controller Identity"
}

resource "google_project_iam_member" "controller_identity_permissions" {
  for_each = toset(local.controller_project_iam_permissions)
  project  = module.project.project_id
  member   = "serviceAccount:${google_service_account.controller_identity.email}"
  role     = each.value
}

data "google_compute_image" "ubuntu" {
  project = "ubuntu-os-cloud"
  family  = "ubuntu-2004-lts"
}

resource "google_compute_instance" "workers" {
  count                   = var.num_workers
  project                 = module.project.project_id
  name                    = format("%s-%s-%s", var.prefix, "worker", count.index)
  machine_type            = "e2-standard-2"
  can_ip_forward          = true
  tags                    = ["iap-access", "worker"]
  zone                    = var.zone
#  metadata_startup_script = var.use_kubeadm ? file("${path.module}/scripts/bootstrap_control_plane_kubeadm.sh") : ""

  metadata = {
    pod-cidr     = "10.200.${count.index}.0/24"
    service-cidr = "10.210.${count.index}.0/24"
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = 100
    }
  }

  network_interface {
    network    = google_compute_network.default.self_link
    subnetwork = google_compute_subnetwork.default.self_link
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = google_service_account.worker_identity.email
  }
}

resource "google_compute_instance" "controllers" {
  count                   = var.num_controllers
  project                 = module.project.project_id
  name                    = format("%s-%s-%s", var.prefix, "controller", count.index)
  machine_type            = "e2-standard-2"
  can_ip_forward          = true
  tags                    = ["iap-access", "controller"]
  zone                    = var.zone
  metadata_startup_script = var.use_kubeadm ? file("${path.module}/scripts/bootstrap_control_plane_kubeadm.sh") : ""

  metadata = {
    pod-cidr               = "10.215.${count.index}.0/24"
    service-cidr           = "10.220.${count.index}.0/24"
    control-plane-endpoint = google_compute_address.kube_api_server_endpoint.0.address
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = 100
    }
  }

  network_interface {
    network    = google_compute_network.default.self_link
    subnetwork = google_compute_subnetwork.default.self_link
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = google_service_account.controller_identity.email
  }
}
