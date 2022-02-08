# Kubernetes The Hard Way

I put this codebase together as preparation for my CKA exam.  The purpose is to install a Kubernetes cluster on plain VMs, so that I can practice real life situations when operating my own Kubernetes cluster.  I'm following along with Kelsey's [guide](https://github.com/kelseyhightower/kubernetes-the-hard-way), combined with the one [KodeKloud](https://github.com/ddometita/mmumshad-kubernetes-the-hard-way/blob/master/docs/01-prerequisites.md) put together.  However, I'm using Terraform for most resources, incl. generating, copying and running bash scripts.  The reason is that this makes it easier to spin up an environment quickly, do some exercises and then destroy everything.

In case people end up here by accident or they are looking for some guidance in addition to the guides linked above, use this repository at your own risk.  I would recommend to go through every section in detail and try and understand what is going on.  What is probably most useful is the first and second section, where I'm creating the infrastructure and the certificates for the different components.  

## Sections
- [Infrastructure](./01_-_infrastructure)
- [Certificates](./02_-_certificates)

# Kubeadm

The CKA exam focuses on using `kubeadm` to create and upgrade the cluster.  For that, I've created a script that creates that installs the necessary binaries (`kubeadm`, `kubectl` and `kubelet`) to create the cluster.  However, this can't be completely automated, so there are a few steps you need to execute manually.

## Update systemd driver
Use the `systemd`-driver for cgroups by updating `/etc/containerd/config.toml` (if you know how to do this with a clever `sed`-command, feel free to raise a PR):
```yaml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```

### kubeadm init
Login on the first controller node and run the following command to initialise the control plane on the first node:
```shell
sudo kubeadm init \
  --control-plane-endpoint "${CONTROL_PLANE_ENDPOINT}:6443" \
  --upload-certs \
  --skip-phases=addon/kube-proxy \
  --pod-network-cidr=$POD_CIDR \
  --service-cidr=$SERVICE_CIDR
```

### Install Cilium
```shell
# Add Helm repo
helm repo add cilium https://helm.cilium.io/

# Install Cilium plugin
helm install cilium cilium/cilium --version 1.11.1 \
    --namespace kube-system \
    --set kubeProxyReplacement=strict \
    --set k8sServiceHost=${CONTROL_PLANE_ENDPOINT} \
    --set k8sServicePort=6443
```

### Regenerate `join`-command

To regenerate the join command for **control-plande nodes**, follow these steps:

```shell
# Upload certs to get a new certificate key
sudo kubeadm init \
  phase upload-certs \
  --upload-certs
  
# Generate the new join command
sudo kubeadm token create --print-join-command
```

Copy the new join-command and add the following:
```shell
--control-plane --certificate-key [CERTIFICATE_KEY_FROM_ABOVE]
```