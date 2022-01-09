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

output "private_key_pem" {
  sensitive = true
  value = tls_private_key.private_key.private_key_pem
}

output "private_key_pem_filepath" {
  value = abspath(local_file.private_key.filename)
}

output "public_key_pem" {
  sensitive = true
  value = (var.is_certificate_authority
    ? tls_self_signed_cert.certificate_authority_certificate.0.cert_pem
    : tls_locally_signed_cert.certificate.0.cert_pem)
}

output "public_key_pem_filepath" {
  value = (var.is_certificate_authority
    ? abspath(local_file.certificate_authority_cert.0.filename)
    : abspath(local_file.certificate.0.filename))
}

