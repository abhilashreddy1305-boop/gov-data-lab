resource "snowflake_service_user" "dbt" {
  name              = "DBT_SVC_USER"
  login_name        = "DBT_SVC_USER"
  rsa_public_key    = var.dbt_public_key
  default_role      = snowflake_account_role.roles["GOV_SVC_DBT"].name
  default_warehouse = snowflake_warehouse.gov_wh.name
  comment           = "dbt automation, managed by Terraform"
}

resource "snowflake_grant_account_role" "dbt_user_role" {
  role_name = snowflake_account_role.roles["GOV_SVC_DBT"].name
  user_name = snowflake_service_user.dbt.name
}