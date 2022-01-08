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
  content = templatefile("${path.module}/templates/backend.other.tf.tpl", {
    REMOTE_STATE_NAME   = "infrastructure"
    REMOTE_STATE_BUCKET = google_storage_bucket.terraform_state_bucket.name
    REMOTE_STATE_PREFIX = local.terraform_state_infra_prefix
    STATE_BUCKET_NAME   = google_storage_bucket.terraform_state_bucket.name
    STATE_PREFIX        = local.terraform_state_certificate_prefix
  })
}