resource "proxmox_virtual_environment_download_file" "boot" {
  for_each = {
    for name, vm in var.vms :
    name => vm
    if vm.image_url != null && vm.image_file_name != null
  }

  node_name    = each.value.node_name
  datastore_id = each.value.image_datastore_id != null ? each.value.image_datastore_id : each.value.datastore_id
  content_type = "iso"

  file_name = each.value.image_file_name
  url       = each.value.image_url
  overwrite = false
}

locals {
  cloud_init_base = <<-EOT
#cloud-config
users:
  - default
  - name: ansible
    groups: [sudo]
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEwHgGwYE2mlHbxJdnxQxr7+0krzV2lcGfRfVCNHCNEE ansible@digitalfault.com
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: "$6$.dBaeiLTokovn3MW$zKEFfuaojU.jpB.jq.9bqjhkOpmFnuDnbBd6TB2xgqOZDIXSE6MiN9si8g2NPVSNL3Kfo7i0Ee2yrzPoAtciR0"
chpasswd:
  expire: false
package_update: true
packages:
  - qemu-guest-agent
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
EOT

  network_configs = {
    for name, vm in var.vms :
    name => <<-EOT
    network:
      version: 2
      renderer: networkd
      ethernets:
        eth0:
          match:
            macaddress: ${vm.mac_address}
          set-name: eth0
          dhcp4: false
          addresses:
            - ${vm.ip_address}
          routes: 
            - to: 0.0.0.0/0
              via: ${vm.gateway}
              on-link: true
          nameservers:
            addresses: [1.1.1.1, 8.8.8.8]
    EOT
  }
}

resource "proxmox_virtual_environment_file" "user_data" {
  for_each = var.vms

  node_name    = each.value.node_name
  datastore_id = each.value.datastore_id
  content_type = "snippets"

  source_raw {
    data      = trimspace(local.cloud_init_base)
    file_name = "cloud-init.yaml"
  }
}

resource "proxmox_virtual_environment_file" "network_data" {
  for_each = var.vms

  node_name    = each.value.node_name
  datastore_id = each.value.datastore_id
  content_type = "snippets"

  source_raw {
    data      = trimspace(local.network_configs[each.key])
    file_name = "cloud-init-network.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  for_each = var.vms

  name        = each.key
  node_name   = each.value.node_name
  on_boot     = true
  tags        = distinct(concat(var.default_tags, each.value.tags))
  description = "Managed by Terraform"

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  bios          = "seabios"

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cpu
    type  = "host"
  }

  memory {
    dedicated = each.value.memory_mb
  }

  network_device {
    bridge = each.value.bridge
    mac_address = each.value.mac_address
  }

  disk {
    datastore_id = each.value.datastore_id
    interface    = "scsi0"
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    ssd          = true
    file_format  = "raw"
    size         = each.value.disk_size_gb
    file_id      = coalesce(each.value.boot_file_id, try(proxmox_virtual_environment_download_file.boot[each.key].id, null))
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = each.value.datastore_id
    user_data_file_id = proxmox_virtual_environment_file.user_data[each.key].id
    network_data_file_id = proxmox_virtual_environment_file.network_data[each.key].id

    # Network is always configured via cloud-init user-data
  }
}
