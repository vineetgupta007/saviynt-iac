terraform {
  required_providers {
    saviynt = {
      source  = "saviynt/saviynt"
      version = ">= 0.3.3"
    }
  }
}

resource "saviynt_endpoint_resource" "this" {
  for_each = var.endpoints

  # --- Required Core Fields ---
  endpoint_name   = each.key
  display_name    = each.value.display_name
  security_system = each.value.associated_system
  description     = lookup(each.value, "description", "Managed by Terraform")

  # --- Connection & Request Logic ---
  owner_type                                    = lookup(each.value, "owner_type", "User")
  requestable                                   = lookup(each.value, "requestable", "true")
  enable_copy_access                            = lookup(each.value, "enable_copy_access", "true")
  block_inflight_request                        = lookup(each.value, "block_inflight_request", "false")
  user_account_correlation_rule                 = lookup(each.value, "correlation_rule", "MATCH_ON_USERNAME")
  disable_new_account_request_if_account_exists = lookup(each.value, "disable_new_acc_if_exists", "false")

  # --- Account Naming & Security ---
  account_name_rule            = lookup(each.value, "account_name_rule", "$${user.username}")
  account_name_validator_regex = lookup(each.value, "name_regex", "^[a-zA-Z0-9_.-]{3,30}$")

  # --- Advanced Queries (Specific to SAP/AD) ---
  access_query                    = lookup(each.value, "access_query", null)
  service_account_access_query    = lookup(each.value, "svc_access_query", null)
  allow_change_password_sql_query = lookup(each.value, "pwd_change_query", null)

  # --- Custom Properties (Dynamic mapping) ---
  # These pull from the cp1, cp2... keys in your variables
  custom_property1 = lookup(each.value, "cp1", null)
  custom_property2 = lookup(each.value, "cp2", null)
  custom_property3 = lookup(each.value, "cp3", null)

  # Labels for the Saviynt UI
  account_custom_property_1_label = lookup(each.value, "cp1_label", "Attribute 1")
  account_custom_property_2_label = lookup(each.value, "cp2_label", "Attribute 2")
  account_custom_property_3_label = lookup(each.value, "cp3_label", "Attribute 3")

  # --- Lifecycle Guard ---
  lifecycle {
    # Recommended for Prod: prevents accidental deletion if a name is mistyped
    prevent_destroy = false
  }
}