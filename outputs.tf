resource "local_sensitive_file" "talosconfig" {
  count           = var.write_outputs ? 1 : 0
  content         = module.talos_cluster.talos_config
  filename        = "${path.module}/output/talosconfig.yaml"
  file_permission = "0600"
}

resource "local_sensitive_file" "kubeconfig" {
  count           = var.write_outputs ? 1 : 0
  content         = module.talos_cluster.kube_config.kubeconfig_raw
  filename        = "${path.module}/output/kubeconfig.yaml"
  file_permission = "0600"
}

output "kubeconfig" {
  description = "Raw kubeconfig"
  value       = module.talos_cluster.kube_config.kubeconfig_raw
  sensitive   = true
}

output "talosconfig" {
  description = "Talos client configuration"
  value       = module.talos_cluster.talos_config
  sensitive   = true
}
