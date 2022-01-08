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

