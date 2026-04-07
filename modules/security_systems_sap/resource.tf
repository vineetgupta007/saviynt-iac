// Copyright (c) 2025 Saviynt Inc.
// SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    saviynt = {
      source  = "saviynt/saviynt"
      version = ">= 0.3.3"
    }
  }
}

resource "saviynt_security_system_resource" "this" {
  systemname                      = var.security_system_name
  display_name                    = var.sec_display_name
  access_add_workflow             = "sapapprovalwf"
  access_remove_workflow          = "sapapprovalwf"
  add_service_account_workflow    = "sapapprovalwf"
  remove_service_account_workflow = "sapapprovalwf"
  automated_provisioning          = "false"
  use_open_connector              = "true"
  recon_application               = "true"
  instant_provision               = "true"
  provisioning_tries              = "3"
  provisioning_comments           = "Auto-provisioned by Terraform"
}