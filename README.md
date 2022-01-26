# Kubernetes The Hard Way

I put this codebase together as preparation for my CKA exam.  The purpose is to install a Kubernetes cluster on plain VMs, so that I can practice real life situations when operating my own Kubernetes cluster.  I'm following along with Kelsey's [guide](https://github.com/kelseyhightower/kubernetes-the-hard-way), combined with the one [KodeKloud](https://github.com/ddometita/mmumshad-kubernetes-the-hard-way/blob/master/docs/01-prerequisites.md) put together.  However, I'm using Terraform for most resources, incl. generating, copying and running bash scripts.  The reason is that this makes it easier to spin up an environment quickly, do some exercises and then destroy everything.

In case people end up here by accident or they are looking for some guidance in addition to the guides linked above, use this repository at your own risk.  I would recommend to go through every section in detail and try and understand what is going on.  What is probably most useful is the first and second section, where I'm creating the infrastructure and the certificates for the different components.  

## Sections
- [Infrastructure](./01_-_infrastructure)
- [Certificates](./02_-_certificates)


# Kubeadm

The CKA exam focuses on using `kubeadm` to create and upgrade the cluster.  For that, I've created a script that creates that installs the necessary binaries (`kubeadm`, `kubectl` and `kubelet`) to create the cluster.  However, this can't be completely automated, so there are a few steps you need to execute manually.

## .bashrc
First, update `.bashrc` with a few environment variables.  We can't do this as part of the startup script, as the script is run as `root` and not as the user you will login with:
```shell
echo 'export SERVICE_CIDR=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/service-cidr)' >> ~/.bashrc
echo 'export CONTROL_PLANE_ENDPOINT=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/control-plane-endpoint)' >> ~/.bashrc
echo 'export POD_CIDR=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/pod-cidr)' >> ~/.bashrc
source ~/.bashrc  
```

## Update systemd driver
Use the `systemd`-driver by updating `/etc/containerd/config.toml`:
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

```shell


helm install cilium cilium/cilium --version 1.11.1 \
    --namespace kube-system \
    --set kubeProxyReplacement=strict \
    --set k8sServiceHost=${CONTROL_PLANE_ENDPOINT} \
    --set k8sServicePort=6443
```