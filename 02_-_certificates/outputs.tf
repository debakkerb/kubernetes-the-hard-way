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

output "certificate_authority_key_path" {
  value = module.certificate_authority.private_key_pem_filepath
}

output "certificate_authority_cert_path" {
  value = module.certificate_authority.public_key_pem_filepath
}

output "kube_proxy_key_path" {
  value = module.proxy_client.private_key_pem_filepath
}

output "kube_proxy_certificate_path" {
  value = module.proxy_client.public_key_pem_filepath
}

output "kube_controller_manager_key_path" {
  value = module.kube_controller_manager.private_key_pem_filepath
}

output "kube_controller_manager_certificate_path" {
  value = module.kube_controller_manager.public_key_pem_filepath
}

output "kube_scheduler_key_pah" {
  value = module.kube_scheduler.private_key_pem_filepath
}

output "kube_scheduler_certificate_path" {
  value = module.kube_scheduler.public_key_pem_filepath
}

output "admin_user_key_path" {
  value = module.admin_user.private_key_pem_filepath
}

output "admin_user_certificate_path" {
  value = module.admin_user.public_key_pem_filepath
}