locals {
  object_roles = [
    "GOV_OBJ_RAW_RW",
    "GOV_OBJ_SILVER_RW",
    "GOV_OBJ_GOLD_RW",
    "GOV_OBJ_GOVERNANCE_RW",
    "GOV_OBJ_SILVER_RO",
    "GOV_OBJ_GOLD_RO",
  ]
  user_roles    = ["GOV_USR_ANALYST", "GOV_USR_RESTRICTED"]
  service_roles = ["GOV_SVC_DBT"]
  all_roles     = toset(concat(local.object_roles, local.user_roles, local.service_roles))
}

resource "snowflake_account_role" "roles" {
  for_each = local.all_roles
  name     = each.key
  comment  = "Governance lab role, managed by Terraform"
}