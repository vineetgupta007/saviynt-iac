output "security_system_resource_id" {
  description = "The unique ID of the created Saviynt Security System Resource."
  value       = saviynt_security_system_resource.this.id
}

output "security_system_resource_name" {
  description = "The System Name (systemname) of the created Saviynt Security System Resource."
  value       = saviynt_security_system_resource.this.systemname
}

output "security_system_resource_display_name" {
  description = "The Display Name (display_name) of the created Saviynt Security System Resource."
  value       = saviynt_security_system_resource.this.display_name
}