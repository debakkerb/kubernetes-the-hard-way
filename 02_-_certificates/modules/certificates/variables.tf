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

variable "algorithm" {
  description = "Algorithm that should be used to generate the certificates and private keys."
  type        = string
  default     = "RSA"
}

variable "rsa_bits" {
  description = "Bit-length for the certificate."
  type        = number
  default     = 2048
}

variable "is_certificate_authority" {
  description = "Indicate whether or not the goal is to generate a certificate authority."
  type        = bool
  default     = false
}

variable "private_key_file_path" {
  description = "Location where the private key will be stored."
}

variable "allowed_use" {
  description = "List of intended usage for the certificate."
  type        = list(string)
  default     = []
}

variable "validity" {
  description = "Number of hours the certs are valid."
  type        = number
  default     = 8760
}

variable "subject" {
  description = "Subject for the certificate."
  type = object({
    common_name  = string
    organization = string
  })
}

variable "ca_public_key_file_path" {
  description = "File path where the public certificate will be stored."
  type        = string
  default     = null
}