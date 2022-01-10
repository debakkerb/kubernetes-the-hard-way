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
  controller_node_names   = data.terraform_remote_state.infrastructure_state.outputs.controller_instance_names
  controller_ip_addresses = data.terraform_remote_state.infrastructure_state.outputs.controller_instance_ip_addresses
  endpoint_urls           = formatlist("%s=https://%s:2380", local.controller_node_names, local.controller_ip_addresses)
  endpoint_urls_text      = join(",", local.endpoint_urls)
}
resource "local_file" "etcd_install_script" {
  filename        = "${path.module}/scripts/bootstrap_etcd.sh"
  file_permission = "0777"
  content = templatefile("${path.module}/templates/bootstrap_etcd.sh.tpl", {
    ENDPOINTS = local.endpoint_urls_text
  })
}

resource "null_resource" "copy_etcd_bootstrap_script" {
  triggers = {
    bootstrap_etcd_script_md5 = md5(local_file.etcd_install_script.content)
  }

  for_each = toset(local.controller_node_names)
  provisioner "local-exec" {
    command = <<-EOT
      gcloud compute scp \
        --zone ${data.terraform_remote_state.infrastructure_state.outputs.zone} \
        --project ${data.terraform_remote_state.infrastructure_state.outputs.project_id} \
        ${path.module}/scripts/bootstrap_etcd.sh \
        ${each.value}:~/
EOT
  }
}

resource "null_resource" "bootstrap_etcd_cluster" {
  triggers = {
    bootstrap_etcd_script_md5 = md5(local_file.etcd_install_script.content)
  }

  for_each = toset(local.controller_node_names)
  provisioner "local-exec" {
    command = <<-EOT
      gcloud compute ssh \
        --zone ${data.terraform_remote_state.infrastructure_state.outputs.zone} \
        --project ${data.terraform_remote_state.infrastructure_state.outputs.project_id} \
        ${each.value} \
        --command "./bootstrap_etcd.sh 2> etcd_err.log 1>etcd_out.log "
EOT
  }

  depends_on = [
    null_resource.copy_etcd_bootstrap_script
  ]
}
