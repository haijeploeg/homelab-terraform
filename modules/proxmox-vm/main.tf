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

    ip_config {
      ipv4 {
        address = each.value.ip_address
        gateway = each.value.gateway
      }
    }

    user_account {
      username = coalesce(each.value.cloud_init_user, var.cloud_init_user_default)
      keys     = coalesce(each.value.cloud_init_ssh_keys, var.cloud_init_ssh_keys_default)
    }
  }
}
