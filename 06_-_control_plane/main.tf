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
  controller_ip_addresses = data.terraform_remote_state.infrastructure_state.outputs.controller_instance_ip_addresses
  controller_urls         = formatlist("https://%s:2379", local.controller_ip_addresses)
  etcd_endpoints_text     = join(",", local.controller_urls)
}

resource "local_file" "control_plane_bootstrap_script" {
  filename = "${path.module}/scripts/bootstrap_control_plane.sh"

  content = templatefile("${path.module}/templates/bootstrap_control_plane.sh.tpl", {
    KUBERNETES_PUBLIC_ADDRESS = data.terraform_remote_state.infrastructure_state.outputs.api_server_endpoint
    ETCD_SERVER_ADDRESSES     = local.etcd_endpoints_text
  })
}

resource "null_resource" "copy_bootstrap_script_to_controllers" {
  for_each = toset(data.terraform_remote_state.infrastructure_state.outputs.controller_instance_names)

  triggers = {
    control_plane_bootstrap_script_md5 = md5(local_file.control_plane_bootstrap_script.content)
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      gcloud compute scp \
        --zone ${data.terraform_remote_state.infrastructure_state.outputs.zone} \
        --project ${data.terraform_remote_state.infrastructure_state.outputs.project_id} \
        ${local_file.control_plane_bootstrap_script.filename} \
        ${each.value}:~/
EOT
  }
}

resource "null_resource" "bootstrap_worker_nodes" {
  for_each = toset(data.terraform_remote_state.infrastructure_state.outputs.controller_instance_names)

  triggers = {
    control_plane_bootstrap_script_md5 = md5(local_file.control_plane_bootstrap_script.content)
  }

  provisioner "local-exec" {
    command = <<-EOT
      gcloud compute ssh \
        --zone ${data.terraform_remote_state.infrastructure_state.outputs.zone} \
        --project ${data.terraform_remote_state.infrastructure_state.outputs.project_id} \
        ${each.value} \
        --command="./bootstrap_control_plane.sh 2> bootstrap_cp_err.log 1>bootstrap_cp_out.log"
EOT
  }

  depends_on = [
    null_resource.copy_bootstrap_script_to_controllers
  ]
}