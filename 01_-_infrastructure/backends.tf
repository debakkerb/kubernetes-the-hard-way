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

resource "local_file" "certificate_backend" {
  filename = "../02_-_certificates/backend.tf"
  content = templatefile("${path.module}/templates/backend.tf.tpl", {
    STATE_BUCKET_NAME                = google_storage_bucket.terraform_state_bucket.name
    STATE_PREFIX                     = format("%s-%s", var.prefix, "certificate-state")
    INCLUDE_CERTIFICATES             = false
    INCLUDE_INFRASTRUCTURE           = true
    CERTIFICATE_REMOTE_STATE_NAME    = null
    CERTIFICATE_STATE_PREFIX         = null
    INFRASTRUCTURE_REMOTE_STATE_NAME = "infrastructure"
    INFRASTRUCTURE_STATE_PREFIX      = local.terraform_state_infra_prefix
  })
}

resource "local_file" "kubeconfig_backend" {
  filename = "../03_-_kubeconfig/backend.tf"
  content = templatefile("${path.module}/templates/backend.tf.tpl", {
    STATE_BUCKET_NAME                = google_storage_bucket.terraform_state_bucket.name
    STATE_PREFIX                     = format("%s-%s", var.prefix, "kubeconfig-state")
    INCLUDE_CERTIFICATES             = true
    INCLUDE_INFRASTRUCTURE           = true
    CERTIFICATE_REMOTE_STATE_NAME    = "certificates"
    CERTIFICATE_STATE_PREFIX         = format("%s-%s", var.prefix, "certificate-state")
    INFRASTRUCTURE_REMOTE_STATE_NAME = "infrastructure"
    INFRASTRUCTURE_STATE_PREFIX      = local.terraform_state_infra_prefix
  })
}

resource "local_file" "encryption_key_backend" {
  filename = "../04_-_encryption_key/backend.tf"
  content = templatefile("${path.module}/templates/backend.tf.tpl", {
    STATE_BUCKET_NAME                = google_storage_bucket.terraform_state_bucket.name
    STATE_PREFIX                     = format("%s-%s", var.prefix, "encryption-key-state")
    INCLUDE_CERTIFICATES             = false
    INCLUDE_INFRASTRUCTURE           = true
    CERTIFICATE_REMOTE_STATE_NAME    = null
    CERTIFICATE_STATE_PREFIX         = null
    INFRASTRUCTURE_REMOTE_STATE_NAME = "infrastructure"
    INFRASTRUCTURE_STATE_PREFIX      = local.terraform_state_infra_prefix
  })
}

resource "local_file" "etcd_backend" {
  filename = "../05_-_etcd/backend.tf"
  content = templatefile("${path.module}/templates/backend.tf.tpl", {
    STATE_BUCKET_NAME                = google_storage_bucket.terraform_state_bucket.name
    STATE_PREFIX                     = format("%s-%s", var.prefix, "etcd-state")
    INCLUDE_CERTIFICATES             = false
    INCLUDE_INFRASTRUCTURE           = true
    CERTIFICATE_REMOTE_STATE_NAME    = null
    CERTIFICATE_STATE_PREFIX         = null
    INFRASTRUCTURE_REMOTE_STATE_NAME = "infrastructure"
    INFRASTRUCTURE_STATE_PREFIX      = local.terraform_state_infra_prefix
  })
}

resource "local_file" "control_plane_backend" {
  filename = "../06_-_control_plane/backend.tf"
  content = templatefile("${path.module}/templates/backend.tf.tpl", {
    STATE_BUCKET_NAME                = google_storage_bucket.terraform_state_bucket.name
    STATE_PREFIX                     = format("%s-%s", var.prefix, "control-plane-state")
    INCLUDE_CERTIFICATES             = false
    INCLUDE_INFRASTRUCTURE           = true
    CERTIFICATE_REMOTE_STATE_NAME    = null
    CERTIFICATE_STATE_PREFIX         = null
    INFRASTRUCTURE_REMOTE_STATE_NAME = "infrastructure"
    INFRASTRUCTURE_STATE_PREFIX      = local.terraform_state_infra_prefix
  })
}

resource "local_file" "worker_nodes_backend" {
  filename = "../07_-_worker_nodes/backend.tf"
  content = templatefile("${path.module}/templates/backend.tf.tpl", {
    STATE_BUCKET_NAME                = google_storage_bucket.terraform_state_bucket.name
    STATE_PREFIX                     = format("%s-%s", var.prefix, "worker-nodes-state")
    INCLUDE_CERTIFICATES             = false
    INCLUDE_INFRASTRUCTURE           = true
    CERTIFICATE_REMOTE_STATE_NAME    = null
    CERTIFICATE_STATE_PREFIX         = null
    INFRASTRUCTURE_REMOTE_STATE_NAME = "infrastructure"
    INFRASTRUCTURE_STATE_PREFIX      = local.terraform_state_infra_prefix
  })
}
