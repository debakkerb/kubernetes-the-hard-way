#!/usr/bin/env bash

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function set_environment() {
  export KUBECONFIG=./03_-_kubeconfig/output/local.kubeconfig
  export KUBERNETES_PUBLIC_ADDRESS=$(cd 01_-_infrastructure && terraform show -json | jq -r .values.outputs.api_server_endpoint.value)
}

echo "Setting environment variables ..."
set_environment
echo "Environment variables set."
