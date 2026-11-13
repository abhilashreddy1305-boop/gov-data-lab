locals {
  role_hierarchy = [
    { child = "GOV_OBJ_GOLD_RO", parent = "GOV_USR_ANALYST" },
    { child = "GOV_USR_ANALYST", parent = "GOV_USR_RESTRICTED" },
    { child = "GOV_OBJ_SILVER_RO", parent = "GOV_USR_RESTRICTED" },
    { child = "GOV_OBJ_RAW_RW", parent = "GOV_SVC_DBT" },
    { child = "GOV_OBJ_SILVER_RW", parent = "GOV_SVC_DBT" },
    { child = "GOV_OBJ_GOLD_RW", parent = "GOV_SVC_DBT" },
    { child = "GOV_OBJ_GOVERNANCE_RW", parent = "GOV_SVC_DBT" },
  ]
}

resource "snowflake_grant_account_role" "hierarchy" {
  for_each         = { for h in local.role_hierarchy : "${h.child}-to-${h.parent}" => h }
  role_name        = snowflake_account_role.roles[each.value.child].name
  parent_role_name = snowflake_account_role.roles[each.value.parent].name
}

# Roll the top-level roles up to SYSADMIN
resource "snowflake_grant_account_role" "to_sysadmin" {
  for_each         = toset(["GOV_USR_RESTRICTED", "GOV_SVC_DBT"])
  role_name        = snowflake_account_role.roles[each.key].name
  parent_role_name = "SYSADMIN"
}

# Give your own user the user roles so you can test them
resource "snowflake_grant_account_role" "to_me" {
  for_each  = toset(["GOV_USR_ANALYST", "GOV_USR_RESTRICTED"])
  role_name = snowflake_account_role.roles[each.key].name
  user_name = var.my_snowflake_user
}