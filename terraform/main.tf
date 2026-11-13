terraform {
  required_version = ">= 1.5.0"
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.0"
    }
  }
}

provider "snowflake" {
  organization_name = var.organization_name
  account_name      = var.account_name
  user              = var.terraform_user
  role              = "GOV_TF_ADMIN"
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = file(var.terraform_private_key_path)
}

locals {
  schemas = toset(["RAW", "SILVER", "GOLD", "GOVERNANCE"])
}

resource "snowflake_database" "gov_lab" {
  name    = "GOV_LAB"
  comment = "Governance lab database, managed by Terraform"
}

resource "snowflake_schema" "layers" {
  for_each = local.schemas
  database = snowflake_database.gov_lab.name
  name     = each.key
  comment  = "Managed by Terraform"
}

resource "snowflake_warehouse" "gov_wh" {
  name                = "GOV_WH"
  warehouse_size      = "XSMALL"
  auto_suspend        = 60
  auto_resume         = true
  initially_suspended = true
  comment             = "Lab warehouse, managed by Terraform"
}