variable "organization_name" {
  type        = string
  description = "Snowflake organization name from CURRENT_ORGANIZATION_NAME()"
}

variable "account_name" {
  type        = string
  description = "Snowflake account name from CURRENT_ACCOUNT_NAME()"
}

variable "terraform_user" {
  type    = string
  default = "TF_SVC_USER"
}

variable "terraform_private_key_path" {
  type        = string
  description = "Path to the Terraform user's private key (.p8)"
}

variable "my_snowflake_user" {
  type        = string
  description = "Your own Snowflake login, so you can test the roles"
}

variable "dbt_public_key" {
  type        = string
  description = "Public key body (one line, no header or footer) for the dbt service user"
}