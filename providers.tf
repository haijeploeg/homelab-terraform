provider "proxmox" {
  endpoint  = var.proxmox.endpoint
  api_token = var.proxmox.api_token
  insecure  = var.proxmox.insecure

  dynamic "ssh" {
    for_each = var.proxmox.ssh == null ? [] : [var.proxmox.ssh]
    content {
      agent       = ssh.value.agent
      username    = ssh.value.username
      private_key = ssh.value.private_key_path != null ? file(pathexpand(ssh.value.private_key_path)) : null
    }
  }
}

provider "talos" {}

provider "kubernetes" {
  host                   = module.talos_cluster.kube_config.kubernetes_client_configuration.host
  client_certificate     = base64decode(module.talos_cluster.kube_config.kubernetes_client_configuration.client_certificate)
  client_key             = base64decode(module.talos_cluster.kube_config.kubernetes_client_configuration.client_key)
  cluster_ca_certificate = base64decode(module.talos_cluster.kube_config.kubernetes_client_configuration.ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = module.talos_cluster.kube_config.kubernetes_client_configuration.host
    client_certificate     = base64decode(module.talos_cluster.kube_config.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(module.talos_cluster.kube_config.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(module.talos_cluster.kube_config.kubernetes_client_configuration.ca_certificate)
  }
}
