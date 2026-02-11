locals {
  controlplane_nodes = [
    for i in range(var.cluster.controlplane_count) : {
      name         = "cp-${i + 1}"
      machine_type = "controlplane"
      ip           = cidrhost(var.cluster.subnet_cidr, var.cluster.controlplane_first_hostnum + i)
      vm_id        = var.cluster.controlplane_vm_id_start + i
      host_node    = var.cluster.proxmox_nodes[i % length(var.cluster.proxmox_nodes)]
    }
  ]

  worker_nodes = [
    for i in range(var.cluster.worker_count) : {
      name         = "worker-${i + 1}"
      machine_type = "worker"
      ip           = cidrhost(var.cluster.subnet_cidr, var.cluster.worker_first_hostnum + i)
      vm_id        = var.cluster.worker_vm_id_start + i
      host_node    = var.cluster.proxmox_nodes[i % length(var.cluster.proxmox_nodes)]
    }
  ]

  nodes = {
    for n in concat(local.controlplane_nodes, local.worker_nodes) : n.name => n
  }

  controlplane_ips = [for n in local.controlplane_nodes : n.ip]
  worker_ips       = [for n in local.worker_nodes : n.ip]
  subnet_prefix    = split("/", var.cluster.subnet_cidr)[1]
}

resource "proxmox_virtual_environment_download_file" "talos" {
  for_each = toset(var.cluster.proxmox_nodes)

  node_name    = each.value
  datastore_id = var.image.datastore_id != null ? var.image.datastore_id : var.cluster.proxmox_datastore
  content_type = "iso"

  file_name               = "talos-${var.image.version}-${var.image.platform}-${var.image.arch}.img"
  url                     = "${var.image.factory_url}/image/${var.image.schematic_id}/${var.image.version}/${var.image.platform}-${var.image.arch}.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = false
}

resource "proxmox_virtual_environment_vm" "this" {
  for_each = local.nodes

  name        = "talos-${each.key}"
  node_name   = each.value.host_node
  on_boot     = true
  vm_id       = each.value.vm_id
  description = each.value.machine_type == "controlplane" ? "Talos Control Plane" : "Talos Worker"
  tags        = each.value.machine_type == "controlplane" ? ["talos", "controlplane"] : ["talos", "worker"]

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  bios          = "seabios"

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.machine_type == "controlplane" ? var.cluster.controlplane_cpu : var.cluster.worker_cpu
    type  = "host"
  }

  memory {
    dedicated = each.value.machine_type == "controlplane" ? var.cluster.controlplane_memory_mb : var.cluster.worker_memory_mb
  }

  network_device {
    bridge = var.cluster.bridge
  }

  disk {
    datastore_id = var.cluster.proxmox_datastore
    interface    = "scsi0"
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    ssd          = true
    file_format  = "raw"
    size         = var.cluster.disk_size_gb
    file_id      = proxmox_virtual_environment_download_file.talos[each.value.host_node].id
  }

  boot_order = ["scsi0"]

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = var.cluster.proxmox_datastore
    ip_config {
      ipv4 {
        address = "${each.value.ip}/${local.subnet_prefix}"
        gateway = var.cluster.gateway
      }
    }
  }
}

resource "talos_machine_secrets" "this" {
  talos_version = var.image.version
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [for n in local.nodes : n.ip]
  endpoints            = local.controlplane_ips
}

data "talos_machine_configuration" "this" {
  for_each = local.nodes

  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${var.cluster.endpoint}:6443"
  machine_type     = each.value.machine_type
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  talos_version      = var.image.version
  kubernetes_version = var.kubernetes_version

  config_patches = [
    yamlencode({
      machine = {
        network = {
          nameservers = var.cluster.dns_servers
          interfaces = [
            merge({
              interface = "eth0"
              addresses = ["${each.value.ip}/${local.subnet_prefix}"]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.cluster.gateway
                }
              ]
              }, each.value.machine_type == "controlplane" ? {
              vip = {
                ip = var.cluster.endpoint
              }
            } : {})
          ]
        }
        time = {
          servers = var.cluster.ntp_servers
        }
      }
      cluster = {
        network = {
          cni = {
            name = "none"
          }
        }
        proxy = {
          disabled = true
        }
        inlineManifests = each.value.machine_type == "controlplane" ? [
          {
            name     = "cilium"
            contents = file("${path.module}/cilium-manifest.yaml")
          }
        ] : []
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "this" {
  for_each = local.nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration
  node                        = each.value.ip
  endpoint                    = each.value.ip

  lifecycle {
    replace_triggered_by = [
      proxmox_virtual_environment_vm.this[each.key]
    ]
  }
}

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplane_nodes[0].ip
  endpoint             = local.controlplane_nodes[0].ip

  depends_on = [talos_machine_configuration_apply.this]
}

data "talos_cluster_health" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  control_plane_nodes  = local.controlplane_ips
  worker_nodes         = local.worker_ips
  endpoints            = local.controlplane_ips

  timeouts = {
    read = "10m"
  }

  depends_on = [talos_machine_bootstrap.this]
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplane_nodes[0].ip
  endpoint             = local.controlplane_nodes[0].ip

  timeouts = {
    read = "1m"
  }

  depends_on = [data.talos_cluster_health.this]
}
