output "endpoint_names" {
  description = "A map of input keys to the actual Saviynt endpoint names."
  # This creates a lookup table: { "SAP_FIN" = "SAP_Finance_Endpoint_Internal_Name" }
  value = { for k, v in saviynt_endpoint_resource.this : k => v.endpoint_name }
}

output "endpoint_ids" {
  description = "A map of input keys to the Saviynt internal resource IDs."
  value       = { for k, v in saviynt_endpoint_resource.this : k => v.id }
}

output "security_system_mappings" {
  description = "A map showing which Security System is linked to which Endpoint."
  value       = { for k, v in saviynt_endpoint_resource.this : k => v.security_system }
}