output "machine_config" {
  description = "Machine configurations for all nodes"
  value       = data.talos_machine_configuration.this
}

output "client_configuration" {
  description = "Talos client configuration"
  value       = data.talos_client_configuration.this
  sensitive   = true
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = talos_cluster_kubeconfig.this
  sensitive   = true
}

output "talos_config" {
  description = "Talos config file contents"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "nodes" {
  description = "Computed node map"
  value       = local.nodes
}
