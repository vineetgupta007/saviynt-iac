variable "saviynt_password" {
  description = "The password for the Saviynt admin user."
  type        = string
  sensitive   = true # Mark as sensitive to prevent it from being shown in logs
}

variable "saviynt_username" {
  description = "The username for the Saviynt admin user."
  type        = string
  # A default can be provided if appropriate, otherwise it must be set in .tfvars
  # default     = "partner_admin" 
}

variable "SAVIYNT_SERVER_URL" {
  type        = string
  description = "Saviynt API Server URL (without https://)"
}

variable "connection_passwords" {
  description = "A map of connection keys to their passwords."
  type        = map(string)
  sensitive   = true
}