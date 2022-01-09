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

echo "Removing etcd configuration ..."
(cd 05_-_etcd && terraform destroy -auto-approve)

echo "Removing encryption keys ..."
(cd 04_-_encryption_key && terraform destroy -auto-approve)

echo "Removing .kubeconfig files ..."
(cd 03_-_kubeconfig && terraform destroy -auto-approve)

echo "Removing certificates ..."
(cd 02_-_certificates && terraform destroy -auto-approve)

echo "Removing instances ..."
(cd 01_-_infrastructure && terraform apply -auto-approve -var=num_workers=0 -var=num_controllers=0)

echo "Recreating instances"
(cd 01_-_infrastructure && terraform apply -auto-approve)

echo "Generating encryption keys"
(cd 02_-_certificates && terraform apply -auto-approve)

echo "Generating kubeconfig files"
(cd 03_-_kubeconfig && terraform apply -auto-approve)

echo "Generating encryption key"
(cd 04_-_encryption_key && terraform apply -auto-approve)

echo "Bootstrapping etcd cluster"
(cd 05_-_etcd && terraform apply -auto-approve)
