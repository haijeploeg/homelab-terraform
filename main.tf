module "talos_cluster" {
  source = "./modules/talos-cluster"

  cluster            = var.cluster
  image              = var.image
  kubernetes_version = var.kubernetes_version
}

module "proxmox_vms" {
  source = "./modules/proxmox-vm"

  default_tags = var.vm_default_tags
  vms          = var.vms
}
