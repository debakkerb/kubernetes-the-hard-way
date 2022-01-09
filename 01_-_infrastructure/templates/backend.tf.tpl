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

provider "google" {
  region = %{if INCLUDE_CERTIFICATES || INCLUDE_INFRASTRUCTURE}data.terraform_remote_state.infrastructure_state.outputs.region%{else}var.region%{endif}
  zone   = %{if INCLUDE_CERTIFICATES || INCLUDE_INFRASTRUCTURE}data.terraform_remote_state.infrastructure_state.outputs.zone%{else}var.zone%{endif}
}

provider "google-beta" {
  region = %{if INCLUDE_CERTIFICATES || INCLUDE_INFRASTRUCTURE}data.terraform_remote_state.infrastructure_state.outputs.region%{else}var.region%{endif}
  zone   = %{if INCLUDE_CERTIFICATES || INCLUDE_INFRASTRUCTURE}data.terraform_remote_state.infrastructure_state.outputs.zone%{else}var.zone%{endif}
}

%{if INCLUDE_CERTIFICATES }
data "terraform_remote_state" "${CERTIFICATE_REMOTE_STATE_NAME}_state" {
  backend = "gcs"
  config = {
    bucket = "${STATE_BUCKET_NAME}"
    prefix = "${CERTIFICATE_STATE_PREFIX}"
  }
}
%{endif}

%{if INCLUDE_INFRASTRUCTURE}
data "terraform_remote_state" "${INFRASTRUCTURE_REMOTE_STATE_NAME}_state" {
  backend = "gcs"
  config = {
    bucket = "${STATE_BUCKET_NAME}"
    prefix = "${INFRASTRUCTURE_STATE_PREFIX}"
  }
}
%{endif}

terraform {
  backend "gcs" {
    bucket = "${STATE_BUCKET_NAME}"
    prefix = "${STATE_PREFIX}"
  }
}