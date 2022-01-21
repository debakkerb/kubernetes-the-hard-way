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
  project_name                       = format("%s-%s", var.prefix, var.project_name)
  terraform_state_bucket_name        = format("%s-%s-%s", var.prefix, var.terraform_state_bucket_name, random_id.random.hex)
  terraform_state_infra_prefix       = format("%s-%s", var.prefix, "infra-state")
  terraform_state_certificate_prefix = format("%s-%s", var.prefix, "certificate-state")
}

resource "random_id" "random" {
  byte_length = 2
}

module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 11.0"

  name              = local.project_name
  random_project_id = true
  org_id            = var.organization_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account_id

  activate_apis = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "networkmanagement.googleapis.com",
    "logging.googleapis.com"
  ]
}

resource "google_storage_bucket" "terraform_state_bucket" {
  project                     = module.project.project_id
  name                        = local.terraform_state_bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 5
    }
  }
}

resource "local_file" "backend_template" {
  filename = "${path.module}/backend.tf"

  content = templatefile("${path.module}/templates/backend.tf.tpl", {
    STATE_BUCKET_NAME                = google_storage_bucket.terraform_state_bucket.name
    STATE_PREFIX                     = format("%s-%s", var.prefix, "infra-state")
    INCLUDE_CERTIFICATES             = false
    INCLUDE_INFRASTRUCTURE           = false
    CERTIFICATE_REMOTE_STATE_NAME    = null
    CERTIFICATE_STATE_PREFIX         = null
    INFRASTRUCTURE_REMOTE_STATE_NAME = null
    INFRASTRUCTURE_STATE_PREFIX      = null
  })
}