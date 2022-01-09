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

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "private_key" {
  filename = var.private_key_file_path
  content  = tls_private_key.private_key.private_key_pem
}

resource "tls_self_signed_cert" "certificate_authority_certificate" {
  count                 = var.is_certificate_authority ? 1 : 0
  allowed_uses          = var.allowed_use
  key_algorithm         = var.algorithm
  private_key_pem       = tls_private_key.private_key.private_key_pem
  validity_period_hours = var.validity
  is_ca_certificate     = var.is_certificate_authority

  subject {
    common_name         = var.subject.common_name
    organization        = var.subject.organization
    country             = var.subject.country_name
    organizational_unit = var.subject.organizational_unit
    locality            = var.subject.locality
  }
}

resource "local_file" "certificate_authority_cert" {
  count    = var.is_certificate_authority ? 1 : 0
  filename = var.public_key_file_path
  content  = tls_self_signed_cert.certificate_authority_certificate.0.cert_pem
}

resource "tls_cert_request" "certificate_request" {
  count           = var.is_certificate_authority ? 0 : 1
  key_algorithm   = tls_private_key.private_key.algorithm
  private_key_pem = tls_private_key.private_key.private_key_pem
  dns_names       = var.dns_names
  ip_addresses    = var.ip_addresses

  subject {
    organization        = var.subject.organization
    common_name         = var.subject.common_name
    country             = var.subject.country_name
    organizational_unit = var.subject.organizational_unit
    locality            = var.subject.locality
  }
}

resource "tls_locally_signed_cert" "certificate" {
  count                 = var.is_certificate_authority ? 0 : 1
  allowed_uses          = var.allowed_use
  validity_period_hours = var.validity
  ca_cert_pem           = var.ca_cert_pem
  ca_key_algorithm      = var.algorithm
  ca_private_key_pem    = var.ca_private_key_pem
  cert_request_pem      = tls_cert_request.certificate_request.0.cert_request_pem
}

resource "local_file" "certificate" {
  count    = var.is_certificate_authority ? 0 : 1
  filename = var.public_key_file_path
  content  = tls_locally_signed_cert.certificate.0.cert_pem
}

