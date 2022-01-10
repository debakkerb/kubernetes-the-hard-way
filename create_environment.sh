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

echo "Creating infrastructure ..."
(cd 01_-_infrastructure && terraform init -reconfigure && terraform apply -auto-approve)

echo "Generating certificates ..."
(cd 02_-_certificates && terraform init -reconfigure && terraform apply -auto-approve)

echo "Generating kubeconfig files ..."
(cd 03_-_kubeconfig && terraform init -reconfigure && terraform apply -auto-approve)

echo "Generating encryption key ..."
(cd 04_-_encryption_key && terraform init -reconfigure && terraform apply -auto-approve)

echo "Bootstrapping etcd cluster ..."
(cd 05_-_etcd && terraform init -reconfigure && terraform apply -auto-approve)

echo "Bootstrap control plane ..."
(cd 06_-_control_plane && terraform init -reconfigure && terraform apply -auto-approve)
