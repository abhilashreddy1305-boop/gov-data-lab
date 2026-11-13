locals {
  schema_access = {
    GOV_OBJ_RAW_RW        = { schema = "RAW", privileges = ["USAGE", "CREATE TABLE", "CREATE VIEW"] }
    GOV_OBJ_SILVER_RW     = { schema = "SILVER", privileges = ["USAGE", "CREATE TABLE", "CREATE VIEW"] }
    GOV_OBJ_GOLD_RW       = { schema = "GOLD", privileges = ["USAGE", "CREATE TABLE", "CREATE VIEW"] }
    GOV_OBJ_GOVERNANCE_RW = { schema = "GOVERNANCE", privileges = ["USAGE", "CREATE TABLE", "CREATE TAG", "CREATE MASKING POLICY", "CREATE ROW ACCESS POLICY"] }
    GOV_OBJ_SILVER_RO     = { schema = "SILVER", privileges = ["USAGE"] }
    GOV_OBJ_GOLD_RO       = { schema = "GOLD", privileges = ["USAGE"] }
  }

  read_only_schemas = {
    GOV_OBJ_SILVER_RO = "SILVER"
    GOV_OBJ_GOLD_RO   = "GOLD"
  }
}

# 1) Every object role can use the database
resource "snowflake_grant_privileges_to_account_role" "database_usage" {
  for_each          = toset(local.object_roles)
  account_role_name = snowflake_account_role.roles[each.key].name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.gov_lab.name
  }
}

# 2) Schema-level privileges, one schema per object role
resource "snowflake_grant_privileges_to_account_role" "schema_privileges" {
  for_each          = local.schema_access
  account_role_name = snowflake_account_role.roles[each.key].name
  privileges        = each.value.privileges
  on_schema {
    schema_name = snowflake_schema.layers[each.value.schema].fully_qualified_name
  }
}

# 3) Read-only roles can SELECT every table created in their schema from now on
resource "snowflake_grant_privileges_to_account_role" "select_future_tables" {
  for_each          = local.read_only_schemas
  account_role_name = snowflake_account_role.roles[each.key].name
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.layers[each.value].fully_qualified_name
    }
  }
}

# 4) Every object role can use the warehouse
resource "snowflake_grant_privileges_to_account_role" "warehouse_usage" {
  for_each          = toset(local.object_roles)
  account_role_name = snowflake_account_role.roles[each.key].name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.gov_wh.name
  }
}

# 5) Only the governance object role may apply policies and tags
resource "snowflake_grant_privileges_to_account_role" "apply_governance" {
  account_role_name = snowflake_account_role.roles["GOV_OBJ_GOVERNANCE_RW"].name
  privileges        = ["APPLY MASKING POLICY", "APPLY ROW ACCESS POLICY", "APPLY TAG"]
  on_account        = true
}