variable "endpoints" {
  description = "A map of endpoint configurations where the key is the unique Endpoint Name."
  type = map(object({
    # --- Required Fields ---
    display_name      = string
    associated_system = string # The technical name of the Security System

    # --- Optional General Settings ---
    description               = optional(string, "Provisioned via Terraform")
    owner_type                = optional(string, "User")
    requestable               = optional(string, "true")
    enable_copy_access        = optional(string, "true")
    block_inflight_request    = optional(string, "false")
    correlation_rule          = optional(string, "MATCH_ON_USERNAME")
    disable_new_acc_if_exists = optional(string, "false")

    # --- Account Naming & Validation ---
    account_name_rule = optional(string, "$${user.username}")
    name_regex        = optional(string, "^[a-zA-Z0-9_.-]{3,30}$")

    # --- Technical Queries (SQL) ---
    access_query     = optional(string)
    svc_access_query = optional(string)
    pwd_change_query = optional(string)

    # --- JSON Configurations ---
    plugin_configs  = optional(string) # JSON string
    endpoint_config = optional(string) # JSON string
    status_config   = optional(string) # JSON string

    # --- Custom Properties (Values) ---
    cp1 = optional(string)
    cp2 = optional(string)
    cp3 = optional(string)
    cp4 = optional(string)
    cp5 = optional(string)

    # --- Custom Properties (Labels for UI) ---
    cp1_label = optional(string)
    cp2_label = optional(string)
    cp3_label = optional(string)
    cp4_label = optional(string)
    cp5_label = optional(string)
  }))
}