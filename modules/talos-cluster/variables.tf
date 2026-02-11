variable "cluster" {
  description = "Talos cluster configuration"
  type = object({
    name                       = string
    endpoint                   = string
    gateway                    = string
    subnet_cidr                = string
    dns_servers                = list(string)
    ntp_servers                = list(string)
    proxmox_nodes              = list(string)
    proxmox_datastore          = string
    bridge                     = string
    controlplane_count         = number
    worker_count               = number
    controlplane_first_hostnum = number
    worker_first_hostnum       = number
    controlplane_vm_id_start   = number
    worker_vm_id_start         = number
    controlplane_cpu           = number
    controlplane_memory_mb     = number
    worker_cpu                 = number
    worker_memory_mb           = number
    disk_size_gb               = number
  })
}

variable "image" {
  description = "Talos image configuration"
  type = object({
    factory_url  = string
    schematic_id = string
    version      = string
    arch         = string
    platform     = string
    datastore_id = optional(string, null)
  })
}

variable "kubernetes_version" {
  description = "Kubernetes version (e.g. 1.30.2)"
  type        = string
}
