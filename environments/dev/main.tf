terraform {
  required_providers {
    saviynt = {
      source  = "saviynt/saviynt"
      version = ">=0.3.3"
    }
  }
}

provider "saviynt" {
  # Use variables or environment variables for these!
  server_url = var.SAVIYNT_SERVER_URL
  username   = var.saviynt_username
  password   = var.saviynt_password
}


locals {
  sys_csv  = csvdecode(file("${path.module}/data/inventory_systems.csv"))
  ep_csv   = csvdecode(file("${path.module}/data/inventory_endpoints.csv"))
  conn_csv = csvdecode(file("${path.module}/data/inventory_adsi_connections.csv"))
  sap_conn_csv = csvdecode(file("${path.module}/data/inventory_sap_connections.csv"))

  # Split systems into two groups based on type
  std_systems = { for s in local.sys_csv : s.key => s if s.type != "SAP" }
  sap_systems = { for s in local.sys_csv : s.key => s if s.type == "SAP" }
}

# 1. Standard Systems (AD, ADSI, etc.)
module "sec_system_std" {
  # Use for_each to loop through the map of standard systems
  for_each = local.std_systems

  source = "../../modules/security_systems_standard"

  # Pass variables directly, using the correct column names from your CSV
  # IMPORTANT: You may need to change "each.value.sys_name", etc.,
  # to match the actual column headers in your inventory_systems.csv file.
  security_system_name = each.value.security_system_name
  sec_display_name     = each.value.sec_display_name
  sec_description      = each.value.sec_description
}

# 2. SAP Systems (SID, Client)
module "sec_system_sap" {
  # Apply the same for_each logic here for the sap systems map
  for_each = local.sap_systems

  source = "../../modules/security_systems_sap"

  # Again, make sure these column names match your CSV file
  security_system_name = each.value.security_system_name
  sec_display_name     = each.value.sec_display_name
  sec_description      = each.value.sec_description
}

# 3. Endpoints (Universal)
module "endpoints" {
  source    = "../../modules/end_points"
  endpoints = { for e in local.ep_csv : e.key => e }
  # Ensure both system modules complete first
  depends_on = [module.sec_system_std, module.sec_system_sap]
}

# 4. Connections (ADSI)
module "adsi_connections" {
  # Use for_each to loop through each row of your connections CSV
  for_each = { for c in local.conn_csv : c.key => c }

  source = "../../modules/connections/ad_connection"

  # Pass all required arguments directly to the module
  # ---
  # IMPORTANT: You must match the values on the right (e.g., each.value.host)
  # to the actual column names in your 'inventory_connections.csv' file.
  # ---
  adsi_connection_name = each.value.key
  LDAP_PROTOCOL        = each.value.LDAP_PROTOCOL # e.g., "ldaps", or from a CSV column
  IP_ADDRESS           = each.value.IP_ADDRESS    # Or the correct column, e.g., "ip_address"
  PASSWORD             = var.connection_passwords[each.key]
  BIND_USER            = each.value.BIND_USER        # Or the correct column from your CSV
  CONNECTION_URL       = each.value.CONNECTION_URL   # Or the correct column from your CSV
  PROVISIONING_URL     = each.value.PROVISIONING_URL # Or the correct column from your CSV
  SAVE_IN_VAULT        = "true"

  # For these VAULT arguments, you need to decide if they are static
  # or also come from your CSV file.
  VAULT_CONNECTION = "your_vault_connection_name"
  VAULT_CONFIG     = "your_vault_config_name"

  #depends_on = [module.endpoints]
}

# 5. Connections (SAP) - NEW MODULE
module "sap_connections" {
  # Use for_each to loop through each row of your SAP connections CSV
  for_each = { for c in local.sap_conn_csv : c.key => c }

  source = "../../modules/connections/sap_connection"

  # IMPORTANT: Match the values on the right (e.g., each.value.jco_ashost)
  # to the actual column names in your 'inventory_sap_connections.csv' file.
  sap_connection_name = each.value.key
  jco_ashost          = each.value.jco_ashost
  jco_sysnr           = each.value.jco_sysnr
  jco_client          = each.value.jco_client
  jco_user            = each.value.jco_user
  password            = var.connection_passwords[each.key] # Assumes password is in a map variable
  jco_r3name          = each.value.jco_r3name
  jco_mshost          = each.value.jco_mshost
  jco_msserv          = each.value.jco_msserv
  jco_group           = each.value.jco_group
  system_name         = each.value.system_name
  prov_jco_ashost     = each.value.prov_jco_ashost
  prov_jco_client     = each.value.prov_jco_client
  prov_jco_mshost     = each.value.prov_jco_mshost
  prov_jco_msserv     = each.value.prov_jco_msserv
  prov_jco_sysnr      = each.value.prov_jco_sysnr
  prov_jco_user       = each.value.prov_jco_user
  prov_password       = var.connection_passwords[each.key] # Assumes password is in a map variable

  # Add other required variables from your sap_connection module here...

  depends_on = [module.sec_system_sap]
}