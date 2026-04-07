variable "security_system_name" {
  description = "The name of Security System in Saviynt eco System. This name cannot be changed once set."
  type        = string
}

variable "sec_display_name" {
  description = "The display name of Security System. This can be business or user friendly name of Security System."
  type        = string
}

variable "sec_description" {
  description = "A brief explanation or business description of what this security system does."
  type        = string
}