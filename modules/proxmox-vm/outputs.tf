output "vm_ids" {
  description = "Map of VM IDs"
  value       = { for k, v in proxmox_virtual_environment_vm.this : k => v.vm_id }
}
