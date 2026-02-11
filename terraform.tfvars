cluster = {
  name                       = "talos"
  endpoint                   = "10.0.0.100"
  gateway                    = "10.0.0.1"
  subnet_cidr                = "10.0.0.0/24"
  proxmox_nodes              = ["proxmox-2"]
  proxmox_datastore          = "vms"
  bridge                     = "vmbr1"
  controlplane_count         = 3
  worker_count               = 3
  controlplane_first_hostnum = 101
  worker_first_hostnum       = 111
  controlplane_vm_id_start   = 200
  worker_vm_id_start         = 300
  controlplane_cpu           = 4
  controlplane_memory_mb     = 8192
  worker_cpu                 = 4
  worker_memory_mb           = 8192
  disk_size_gb               = 20
}

image = {
  factory_url  = "https://factory.talos.dev"
  schematic_id = "3abf06e1d81e509d779dc256f9feae6cd6d82c69337c661cbfc383a92594faf5"
  version      = "v1.12.2"
  arch         = "amd64"
  platform     = "nocloud"
  datastore_id = "templates"
}

kubernetes_version = "1.35.0"

vms = {
  "loadbalancer.digitalfault.com" = {
    node_name          = "proxmox-2"
    vm_id              = 400
    cpu                = 2
    memory_mb          = 4096
    datastore_id       = "vms"
    disk_size_gb       = 20
    bridge             = "vmbr0"
    mac_address        = "00:50:56:00:74:95"
    ip_address         = "144.76.195.209/27"
    gateway            = "144.76.195.193"
    image_url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
    image_file_name    = "ubuntu-24.04-cloudimg-amd64.img"
    image_datastore_id = "templates"

  }
}
