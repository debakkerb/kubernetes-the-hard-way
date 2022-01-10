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

resource "null_resource" "copy_bootstrap_nodes_scripts" {
  for_each = toset(data.terraform_remote_state.infrastructure_state.outputs.worker_instance_names)

  provisioner "local-exec" {
    command = <<-EOT
      gcloud compute scp \
        --zone ${data.terraform_remote_state.infrastructure_state.outputs.zone} \
        --project ${data.terraform_remote_state.infrastructure_state.outputs.project_id} \
        ${path.module}/scripts/bootstrap_worker_nodes.sh \
        ${each.value}:~/
EOT
  }
}

resource "null_resource" "bootstrap_workers" {
  for_each = toset(data.terraform_remote_state.infrastructure_state.outputs.worker_instance_names)
  provisioner "local-exec" {
    command = <<-EOT
      gcloud compute ssh \
        --zone ${data.terraform_remote_state.infrastructure_state.outputs.zone} \
        --project ${data.terraform_remote_state.infrastructure_state.outputs.project_id} \
        ${each.value} \
        --command "./bootstrap_worker_nodes.sh 2> worker_err.log 1>worker_out.log "
EOT
  }

  depends_on = [
    null_resource.copy_bootstrap_nodes_scripts
  ]
}
