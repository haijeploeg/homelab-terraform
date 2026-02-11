# Talos Cluster Module

Deploy Talos Kubernetes cluster on Proxmox.

## Inputs

- `cluster` - Cluster configuration object
- `image` - Talos image configuration  
- `kubernetes_version` - Kubernetes version (e.g. "1.30.2")

## Outputs

- `kubeconfig_path` - Path to generated kubeconfig file
- `talosconfig_path` - Path to generated talosconfig file

## Example Usage

```hcl
module "talos_cluster" {
  source = "./modules/talos-cluster"
  
  cluster = var.cluster
  image   = var.image
  kubernetes_version = "1.30.2"
}
```

## Features

- Creates Talos VMs on Proxmox
- Bootstraps Kubernetes cluster
- Supports both control plane and worker nodes
- Configures networking and storage
- Generates access configurations