# Proxmox VM Module

Create standalone VMs on Proxmox VE.

## Inputs

- `default_tags` - List of tags applied to all VMs
- `vms` - Map of VM definitions with the following attributes:
  - `node_name` - Proxmox node name
  - `vm_id` - VM ID number
  - `cpu` - Number of CPU cores
  - `memory_mb` - Memory in MB
  - `datastore_id` - Storage datastore ID
  - `disk_size_gb` - Disk size in GB
  - `bridge` - Network bridge (default: "vmbr0")
  - `ip_address` - Static IP address (optional)
  - `gateway` - Network gateway (optional)
  - `tags` - Additional VM tags (optional)
  - `boot_file_id` - Custom boot file ID (optional)
  - `image_url` - Download URL for a boot image (optional)
  - `image_file_name` - File name to store the downloaded image (optional)
  - `image_datastore_id` - Datastore for the downloaded image (optional; defaults to `datastore_id`)
  - `cloud_init_user` - Cloud-init username (optional)
  - `cloud_init_ssh_keys` - Cloud-init SSH public keys (optional)

- Module defaults:
  - `cloud_init_user_default` - Default cloud-init username (defaults to `ansible`)
  - `cloud_init_ssh_keys_default` - Default SSH public keys (defaults to ansible key)

## Example Usage

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
      tags         = ["test", "ubuntu"]
      image_url         = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
      image_file_name   = "ubuntu-24.04-cloudimg-amd64.img"
      image_datastore_id = "templates"
      cloud_init_user     = "ansible"
      cloud_init_ssh_keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEwHgGwYE2mlHbxJdnxQxr7+0krzV2lcGfRfVCNHCNEE ansible@digitalfault.com"
      ]
    }
  }
}
```

## Features

- Create multiple VMs with different configurations
- Support for static IP configuration
- Automatic network and storage setup
- Flexible tagging system
