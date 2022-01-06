# Kubernetes The Hard Way

I put this codebase together as preparation for my CKA exam.  The purpose is to install a Kubernetes cluster on plain VMs, so that I can practice real life situations when operating my own Kubernetes cluster.  I'm following along with Kelsey's [guide](https://github.com/kelseyhightower/kubernetes-the-hard-way), combined with the one [KodeKloud](https://github.com/ddometita/mmumshad-kubernetes-the-hard-way/blob/master/docs/01-prerequisites.md) put together.  However, I'm using Terraform for most resources, incl. generating, copying and running bash scripts.  The reason is that this makes it easier to spin up an environment quickly, do some exercises and then destroy everything.

In case people end up here by accident or they are looking for some guidance in addition to the guides linked above, use this repository at your own risk.  I would recommend to go through every section in detail and try and understand what is going on.  What is probably most useful is the first and second section, where I'm creating the infrastructure and the certificates for the different components.  

## Sections
- [Infrastructure](./01_-_infrastructure)
- [Certificates](./02_-_certificates)

