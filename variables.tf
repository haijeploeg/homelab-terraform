variable "proxmox" {
  description = "Proxmox connection configuration"
  type = object({
    endpoint  = string
    insecure  = bool
    api_token = string
    node      = string
    ssh = optional(object({
      agent            = optional(bool, true)
      username         = optional(string, "root")
      private_key_path = optional(string)
    }))
  })
  sensitive = true

  validation {
    condition     = can(regex("^https?://", var.proxmox.endpoint))
    error_message = "Proxmox endpoint must start with http:// or https://."
  }
}

variable "cluster" {
  description = "Talos cluster configuration"
  type = object({
    name                       = string
    endpoint                   = string
    gateway                    = string
    subnet_cidr                = string
    dns_servers                = optional(list(string), ["1.1.1.1", "8.8.8.8"])
    ntp_servers                = optional(list(string), ["pool.ntp.org"])
    proxmox_nodes              = list(string)
    proxmox_datastore          = string
    bridge                     = optional(string, "vmbr0")
    controlplane_count         = optional(number, 3)
    worker_count               = optional(number, 3)
    controlplane_first_hostnum = optional(number, 101)
    worker_first_hostnum       = optional(number, 111)
    controlplane_vm_id_start   = optional(number, 200)
    worker_vm_id_start         = optional(number, 300)
    controlplane_cpu           = optional(number, 4)
    controlplane_memory_mb     = optional(number, 8192)
    worker_cpu                 = optional(number, 4)
    worker_memory_mb           = optional(number, 8192)
    disk_size_gb               = optional(number, 20)
  })

  validation {
    condition     = var.cluster.controlplane_count >= 1 && var.cluster.controlplane_count <= 5
    error_message = "Control plane count must be between 1 and 5."
  }
}

variable "image" {
  description = "Talos image configuration"
  type = object({
    factory_url  = optional(string, "https://factory.talos.dev")
    schematic_id = string
    version      = string
    arch         = optional(string, "amd64")
    platform     = optional(string, "nocloud")
    datastore_id = optional(string, null)
  })
}

variable "kubernetes_version" {
  description = "Kubernetes version (e.g. 1.30.2)"
  type        = string
}

variable "vm_default_tags" {
  description = "Tags applied to standalone VMs"
  type        = list(string)
  default     = []
}

variable "vms" {
  description = "Standalone VM definitions"
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
  default = {}
}

variable "write_outputs" {
  description = "Write kubeconfig and talosconfig into output/"
  type        = bool
  default     = true
}
