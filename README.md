# Homelab Talos on Proxmox

Simple Terraform setup to deploy a Talos Kubernetes cluster (3 control planes + 3 workers) on Proxmox, with Cilium installed via Helm.

## What this does

- Creates Talos VMs on Proxmox
- Bootstraps the Talos cluster
- Installs Cilium with a Helm chart
- Exposes kubeconfig and talosconfig

## Requirements

- Terraform >= 1.6
- Proxmox VE 8.x
- `talosctl` and `kubectl`

## Quick start

1) Configure `terraform.tfvars` (see `terraform.tfvars.example`).
2) Run Terraform:

```bash
terraform init
terraform apply
```

3) Use outputs:

```bash
export KUBECONFIG=./output/kubeconfig.yaml
kubectl get nodes
```

## Modules

- `modules/talos-cluster`: Talos cluster on Proxmox
- `modules/proxmox-vm`: Create standalone Proxmox VMs

### Standalone VM example

```hcl
module "proxmox_vms" {
  source = "./modules/proxmox-vm"

  default_tags = ["lab"]
  vms = {
    "vm-test-1" = {
      node_name    = "pve"
      vm_id        = 500
      cpu          = 2
      memory_mb    = 2048
      datastore_id = "local-lvm"
      disk_size_gb = 20
      bridge       = "vmbr0"
      ip_address   = "192.168.1.50/24"
      gateway      = "192.168.1.1"
    }
  }
}
```

## Notes on versions

Terraform providers do not accept `latest` as a version. This project uses permissive constraints (">= 0.0.0") so Terraform can select the latest compatible provider at init time. For Talos/Kubernetes/Cilium versions, set explicit versions in `terraform.tfvars`.
