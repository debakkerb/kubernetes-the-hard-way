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

resource "random_string" "encryption_key" {
  length  = 32
  number  = true
  lower   = true
  upper   = true
  special = true
}

resource "local_file" "encryption_key_config" {
  filename = "${path.module}/output/encryption-config.yaml"
  content = templatefile("${path.module}/templates/encryption_config.yaml.tpl", {
    ENCRYPTION_KEY = base64encode(random_string.encryption_key.result)
  })
}

resource "null_resource" "copy_config_to_control_plane" {
  triggers = {
    zone          = data.terraform_remote_state.infrastructure_state.outputs.zone
    project_id       = data.terraform_remote_state.infrastructure_state.outputs.project_id
    instance_name = each.value
  }

  for_each = toset(data.terraform_remote_state.infrastructure_state.outputs.controller_instance_names)
  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      gcloud compute scp \
        --zone ${data.terraform_remote_state.infrastructure_state.outputs.zone} \
        --project ${data.terraform_remote_state.infrastructure_state.outputs.project_id} \
        ${abspath(local_file.encryption_key_config.filename)} \
        ${each.value}:~/
EOT
  }
}