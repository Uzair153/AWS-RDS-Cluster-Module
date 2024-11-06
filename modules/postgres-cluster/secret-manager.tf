
resource "random_string" "rds_password_symbol" {
  length           = 4
  special          = true    # Ensure it only generates special characters
  upper            = false   # Disable uppercase letters
  lower            = false   # Disable lowercase letters
 
  # Limit special characters to those allowed by AWS Secrets Manager
  override_special = "/_+=.@-"
}

# ----------------------------------Secrets Manager for storing DB credentials------------------------------------------------------

resource "aws_secretsmanager_secret" "rds_master_password" {
  name        = "${var.environment}-rds-master-password-${random_string.rds_password_symbol.result}"
  description = "Master password for RDS in ${var.environment} environment"
}
