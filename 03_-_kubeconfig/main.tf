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
  ca_certificate_key_path = data.terraform_remote_state.certificates_state.outputs.certificate_authority_cert_path
}

resource "null_resource" "kubelet_kubeconfig" {
  for_each = toset(data.terraform_remote_state.infrastructure_state.outputs.worker_instance_names)

  triggers = {
    kube_config_sh_md5 = filemd5("${path.module}/scripts/kube_config.sh")
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      ${path.module}/scripts/kube_config.sh \
        ${local.ca_certificate_key_path} \
        ${data.terraform_remote_state.infrastructure_state.outputs.api_server_endpoint} \
        ${path.module}/output/${each.value}.kubeconfig \
        system:node:${each.value} \
        ../02_-_certificates/output/kubelet-${each.value}.pem \
        ../02_-_certificates/output/kubelet-${each.value}-key.pem
EOT
  }
}

resource "null_resource" "kube_proxy_kubeconfig" {
  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      ${path.module}/scripts/kube_config.sh \
        ${local.ca_certificate_key_path} \
        ${data.terraform_remote_state.infrastructure_state.outputs.api_server_endpoint} \
        ${path.module}/output/kube-proxy.kubeconfig \
        system:kube-proxy \
        ${data.terraform_remote_state.certificates_state.outputs.kube_proxy_certificate_path} \
        ${data.terraform_remote_state.certificates_state.outputs.kube_proxy_key_path}
EOT
  }
}

resource "null_resource" "kube_controller_manager_kubeconfig" {
  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      ${path.module}/scripts/kube_config.sh \
        ${local.ca_certificate_key_path} \
        ${data.terraform_remote_state.infrastructure_state.outputs.api_server_endpoint} \
        ${path.module}/output/kube-controller-manager.kubeconfig \
        system:kube-controller-manager \
        ${data.terraform_remote_state.certificates_state.outputs.kube_controller_manager_certificate_path} \
        ${data.terraform_remote_state.certificates_state.outputs.kube_controller_manager_key_path}
EOT
  }
}

resource "null_resource" "kube_scheduler_kubeconfig" {
  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      ${path.module}/scripts/kube_config.sh \
        ${local.ca_certificate_key_path} \
        ${data.terraform_remote_state.infrastructure_state.outputs.api_server_endpoint} \
        ${path.module}/output/kube-scheduler.kubeconfig \
        system:kube-scheduler \
        ${data.terraform_remote_state.certificates_state.outputs.kube_scheduler_certificate_path} \
        ${data.terraform_remote_state.certificates_state.outputs.kube_scheduler_key_pah}
EOT
  }
}

resource "null_resource" "admin_kubeconfig" {
  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      ${path.module}/scripts/kube_config.sh \
        ${local.ca_certificate_key_path} \
        ${data.terraform_remote_state.infrastructure_state.outputs.api_server_endpoint} \
        ${path.module}/output/admin.kubeconfig \
        system:admin \
        ${data.terraform_remote_state.certificates_state.outputs.admin_user_certificate_path} \
        ${data.terraform_remote_state.certificates_state.outputs.admin_user_key_path}
EOT
  }
}

resource "null_resource" "copy_kubeconfig_to_workers" {
  for_each = toset(data.terraform_remote_state.infrastructure_state.outputs.worker_instance_names)
  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      gcloud compute scp \
        --zone ${data.terraform_remote_state.infrastructure_state.outputs.zone} \
        --project ${data.terraform_remote_state.infrastructure_state.outputs.project_id} \
        ${path.module}/output/${each.value}.kubeconfig \
        ${path.module}/output/kube-proxy.kubeconfig \
        ${each.value}:~/
EOT
  }

  depends_on = [
    null_resource.kube_proxy_kubeconfig,
    null_resource.kubelet_kubeconfig
  ]
}

resource "null_resource" "copy_kubeconfig_to_controllers" {
  for_each = toset(data.terraform_remote_state.infrastructure_state.outputs.controller_instance_names)
  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      gcloud compute scp \
        --zone ${data.terraform_remote_state.infrastructure_state.outputs.zone} \
        --project ${data.terraform_remote_state.infrastructure_state.outputs.project_id} \
        ${path.module}/output/admin.kubeconfig \
        ${path.module}/output/kube-controller-manager.kubeconfig \
        ${path.module}/output/kube-scheduler.kubeconfig \
        ${each.value}:~/
EOT
  }

  depends_on = [
    null_resource.admin_kubeconfig,
    null_resource.kube_controller_manager_kubeconfig,
    null_resource.kube_scheduler_kubeconfig
  ]
}


