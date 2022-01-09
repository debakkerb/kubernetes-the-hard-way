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

CERTIFICATE_AUTHORITY=$1
SERVER_IP_ADDRESS=$2
KUBECONFIG_FILENAME=$3

USERNAME=$4
CLIENT_CERTIFICATE=$5
CLIENT_CERTIFICATE_KEY=$6

echo "Creating .kubeconfig files for the different layers."

echo "Adding cluster information ..."
kubectl config set-cluster kubernetes \
  --certificate-authority=${CERTIFICATE_AUTHORITY} \
  --embed-certs=true \
  --server=https://${SERVER_IP_ADDRESS}:6443 \
  --kubeconfig=${KUBECONFIG_FILENAME}

#echo "Adding user credentials ..."
#kubectl config set-credentials ${USERNAME} \
#  --client-certificate=${CLIENT_CERTIFICATE} \
#  --client-key=${CLIENT_CERTIFICATE_KEY} \
#  --embed-certs=true \
#  --kubeconfig=${KUBECONFIG_FILENAME}
#
#echo "Linking cluster to credentials ..."
#kubectl config set-context default \
#  --cluster=kubernetes \
#  --user=${USERNAME} \
#  --kubeconfig=${KUBECONFIG_FILENAME}
