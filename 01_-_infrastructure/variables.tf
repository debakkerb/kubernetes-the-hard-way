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

variable "billing_account_id" {
  description = "Billing account ID to attach to the project."
  type        = string
}

variable "organization_id" {
  description = "Organization ID where the project should be created."
  type        = string
  default     = null
}

variable "folder_id" {
  description = "Parent folder ID for the project."
  type        = string
  default     = null
}

variable "prefix" {
  description = "Prefix to be used for resource names."
  type        = string
  default     = "khw"
}

variable "project_name" {
  description = "Name for the project."
  type        = string
  default     = "plain-kubernetes"
}

variable "region" {
  description = "Region where all resources will be created."
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone where all resources will be created, unless they are regional."
  type        = string
  default     = "europe-west1-b"
}

variable "terraform_state_bucket_name" {
  description = "Name of the GCS bucket where the TF state will be hosted."
  type        = string
  default     = "k8s-tf-state"
}

variable "network_name" {
  description = "Name for the network."
  type        = string
  default     = "k8s-cluster-nw"
}

variable "subnet_name" {
  description = "Name for the subnet."
  type        = string
  default     = "k8s-cluster-snw"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet."
  type        = string
  default     = "10.0.0.0/24"
}

variable "enable_egress_traffic" {
  description = "Enable egress traffic.  Necessary to download Kubernetes binaries, ..."
  type        = bool
  default     = true
}

variable "num_workers" {
  description = "Number of workers to create."
  type        = number
  default     = 0
}

variable "num_controllers" {
  description = "Number of controllers to create"
  type        = number
  default     = 0
}

variable "create_public_ip_address" {
  description = "Whether or not to create a static IP address, as these incur an extra cost."
  type        = bool
  default     = true
}