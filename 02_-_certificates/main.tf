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
  certificate_allowed_usage = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth"
  ]
}

module "certificate_authority" {
  source                   = "./modules/certificates"
  is_certificate_authority = true
  private_key_file_path    = "${path.module}/output/ca-key.pem"
  public_key_file_path     = "${path.module}/output/ca.pem"
  allowed_use              = ["cert_signing", "crl_signing"]

  subject = {
    common_name         = "Kubernetes"
    organization        = "Kubernetes"
    country_name        = "BE"
    organizational_unit = "K8S"
    locality            = "NA"
  }
}

module "admin_user" {
  source = "./modules/certificates"

  private_key_file_path = "${path.module}/output/admin-key.pem"
  public_key_file_path  = "${path.module}/output/admin.pem"
  allowed_use           = local.certificate_allowed_usage
  ca_private_key_pem    = module.certificate_authority.private_key_pem
  ca_cert_pem           = module.certificate_authority.public_key_pem

  subject = {
    common_name         = "Kubernetes"
    organization        = "system:masters"
    country_name        = "BE"
    organizational_unit = "K8S"
    locality            = "NA"
  }
}

module "kube_controller_manager" {
  source = "./modules/certificates"

  private_key_file_path = "${path.module}/output/kube-controller-manager-key.pem"
  public_key_file_path  = "${path.module}/output/kube-controller-manager.pem"
  allowed_use           = local.certificate_allowed_usage
  ca_private_key_pem    = module.certificate_authority.private_key_pem
  ca_cert_pem           = module.certificate_authority.public_key_pem

  subject = {
    common_name         = "system:kube-controller-manager"
    organization        = "system:kube-controller-manager"
    country_name        = "BE"
    organizational_unit = "K8S"
    locality            = "NA"
  }
}

module "proxy_client" {
  source = "./modules/certificates"

  private_key_file_path = "${path.module}/output/kube-proxy-key.pem"
  public_key_file_path  = "${path.module}/output/kube-proxy.pem"
  allowed_use           = local.certificate_allowed_usage
  ca_private_key_pem    = module.certificate_authority.private_key_pem
  ca_cert_pem           = module.certificate_authority.public_key_pem

  subject = {
    common_name         = "system:kube-proxy"
    organization        = "system:node-proxier"
    country_name        = "BE"
    organizational_unit = "K8S"
    locality            = "NA"
  }
}

module "kube_scheduler" {
  source = "./modules/certificates"

  private_key_file_path = "${path.module}/output/kube-scheduler-key.pem"
  public_key_file_path  = "${path.module}/output/kube-scheduler.pem"
  allowed_use           = local.certificate_allowed_usage
  ca_private_key_pem    = module.certificate_authority.private_key_pem
  ca_cert_pem           = module.certificate_authority.public_key_pem

  subject = {
    common_name         = "system:kube-scheduler"
    organization        = "system:kube-scheduler"
    country_name        = "BE"
    organizational_unit = "K8S"
    locality            = "NA"
  }
}

module "kube_api_server" {
  source = "./modules/certificates"

  private_key_file_path = "${path.module}/output/kubernetes-key.pem"
  public_key_file_path  = "${path.module}/output/kubernetes.pem"
  allowed_use           = local.certificate_allowed_usage
  ca_private_key_pem    = module.certificate_authority.private_key_pem
  ca_cert_pem           = module.certificate_authority.public_key_pem

  dns_names = [
    "kubernetes,kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.svc.cluster.local"
  ]

  ip_addresses = concat([
    data.terraform_remote_state.infrastructure_state.outputs.api_server_endpoint,
    "127.0.0.1",
  ], data.terraform_remote_state.infrastructure_state.outputs.controller_instance_ip_addresses)

  subject = {
    common_name         = "kubernetes"
    organization        = "Kubernetes"
    country_name        = "BE"
    organizational_unit = "K8S"
    locality            = "NA"
  }
}

module "service_account_keypair" {
  source = "./modules/certificates"

  private_key_file_path = "${path.module}/output/service-account-key.pem"
  public_key_file_path  = "${path.module}/output/service-account.pem"
  allowed_use           = local.certificate_allowed_usage
  ca_private_key_pem    = module.certificate_authority.private_key_pem
  ca_cert_pem           = module.certificate_authority.public_key_pem

  subject = {
    common_name         = "service-accounts"
    organization        = "Kubernetes"
    country_name        = "BE"
    organizational_unit = "K8S"
    locality            = "NA"
  }
}


module "kubelet" {
  for_each = {
    for instance in data.terraform_remote_state.infrastructure_state.outputs.workers :
    instance.name => instance
  }
  source = "./modules/certificates"

  private_key_file_path = "${path.module}/output/kubelet-${each.value.name}-key.pem"
  public_key_file_path  = "${path.module}/output/kubelet-${each.value.name}.pem"
  allowed_use           = local.certificate_allowed_usage
  ca_private_key_pem    = module.certificate_authority.private_key_pem
  ca_cert_pem           = module.certificate_authority.public_key_pem

  dns_names = [
    each.value.name
  ]

  ip_addresses = [
    each.value.network_interface.0.network_ip
  ]

  subject = {
    common_name         = "service-accounts"
    organization        = "Kubernetes"
    country_name        = "BE"
    organizational_unit = "K8S"
    locality            = "NA"
  }
}

resource "null_resource" "copy_certificates_to_controllers" {
  for_each = toset(data.terraform_remote_state.infrastructure_state.outputs.controller_instance_names)

  triggers = {
    ca_pem_md5                  = md5(module.certificate_authority.public_key_pem)
    ca_key_pem_md5              = md5(module.certificate_authority.private_key_pem)
    kube_api_server_pem_md5     = md5(module.kube_api_server.public_key_pem)
    kube_api_server_key_pem_md5 = md5(module.kube_api_server.private_key_pem)
    service_account_pem_md5     = md5(module.service_account_keypair.public_key_pem)
    service_account_key_pem_md5 = md5(module.service_account_keypair.private_key_pem)

    project_id    = data.terraform_remote_state.infrastructure_state.outputs.project_id
    zone          = data.terraform_remote_state.infrastructure_state.outputs.zone
    instance_name = each.value
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      gcloud compute scp \
        --zone ${data.terraform_remote_state.infrastructure_state.outputs.zone} \
        --project ${data.terraform_remote_state.infrastructure_state.outputs.project_id} \
        ${path.module}/output/ca.pem \
        ${path.module}/output/ca-key.pem \
        ${path.module}/output/kubernetes-key.pem \
        ${path.module}/output/kubernetes.pem \
        ${path.module}/output/service-account-key.pem \
        ${path.module}/output/service-account.pem \
        ${each.value}:~/
EOT
  }
}

resource "null_resource" "copy_certificates_to_workers" {
  for_each = toset(data.terraform_remote_state.infrastructure_state.outputs.worker_instance_names)

  triggers = {
    ca_pem_md5          = md5(module.certificate_authority.public_key_pem)
    ca_key_pem_md5      = md5(module.certificate_authority.private_key_pem)
    kubelet_pem_md5     = md5(module.kubelet[each.value].public_key_pem)
    kubelet_key_pem_md5 = md5(module.kubelet[each.value].private_key_pem)

    project_id    = data.terraform_remote_state.infrastructure_state.outputs.project_id
    zone          = data.terraform_remote_state.infrastructure_state.outputs.zone
    instance_name = each.value
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      gcloud compute scp \
        --zone ${data.terraform_remote_state.infrastructure_state.outputs.zone} \
        --project ${data.terraform_remote_state.infrastructure_state.outputs.project_id} \
        ${path.module}/output/ca.pem \
        ${path.module}/output/ca-key.pem \
        ${path.module}/output/kubelet-${each.value}.pem \
        ${path.module}/output/kubelet-${each.value}-key.pem \
        ${each.value}:~/
EOT
  }
}
