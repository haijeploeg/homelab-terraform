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
    mac_address  = string
    ip_address   = string
    gateway      = string
    tags         = optional(list(string), [])
    boot_file_id = optional(string)

    image_url          = optional(string)
    image_file_name    = optional(string)
    image_datastore_id = optional(string)

  }))
}
