variable "default_tags" {
  description = "Tags applied to all VMs"
  type        = list(string)
  default     = []
}

variable "vms" {
  description = "Map of VM definitions"
  type = map(object({
    node_name    = string
    vm_id        = number
    cpu          = number
    memory_mb    = number
    datastore_id = string
    disk_size_gb = number
    bridge       = optional(string, "vmbr0")
    ip_address   = string
    gateway      = string
    tags         = optional(list(string), [])
    boot_file_id = optional(string)

    image_url          = optional(string)
    image_file_name    = optional(string)
    image_datastore_id = optional(string)

    cloud_init_user     = optional(string)
    cloud_init_ssh_keys = optional(list(string))
  }))
}

variable "cloud_init_user_default" {
  description = "Default cloud-init username"
  type        = string
  default     = "ansible"
}

variable "cloud_init_ssh_keys_default" {
  description = "Default cloud-init SSH public keys"
  type        = list(string)
  default = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEwHgGwYE2mlHbxJdnxQxr7+0krzV2lcGfRfVCNHCNEE ansible@digitalfault.com"
  ]
}
