# variables.tf
variable "sap_connection_name" {
  type        = string
  description = "The unique name for the SAP connection"
}

variable "jco_ashost" {
  type        = string
  description = "The application server host for the JCo connection."
}

variable "jco_sysnr" {
  type        = string
  description = "The system number for the JCo connection."
}

variable "jco_client" {
  type        = string
  description = "The client number for the JCo connection."
}

variable "jco_user" {
  type        = string
  description = "The user for the JCo connection."
}

variable "password" {
  type        = string
  description = "The password for the JCo connection user."
  sensitive   = true
}

variable "jco_r3name" {
  type        = string
  description = "The R3 name for the JCo connection."
}

variable "jco_mshost" {
  type        = string
  description = "The message server host for the JCo connection."
}

variable "jco_msserv" {
  type        = string
  description = "The message server service for the JCo connection."
}

variable "jco_group" {
  type        = string
  description = "The logon group for the JCo connection."
}

variable "system_name" {
  type        = string
  description = "The system name for the SAP instance."
}

variable "prov_jco_ashost" {
  type        = string
  description = "The application server host for provisioning."
}

variable "prov_jco_sysnr" {
  type        = string
  description = "The system number for provisioning."
}

variable "prov_jco_client" {
  type        = string
  description = "The client number for provisioning."
}

variable "prov_jco_user" {
  type        = string
  description = "The user for provisioning."
}

variable "prov_password" {
  type        = string
  description = "The password for the provisioning user."
  sensitive   = true
}

variable "prov_jco_mshost" {
  type        = string
  description = "The message server host for provisioning."
}

variable "prov_jco_msserv" {
  type        = string
  description = "The message server service for provisioning."
}