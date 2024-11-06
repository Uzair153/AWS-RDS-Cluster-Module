#-----------------------------------Generate random password for the master user-----------------------------------------------------

resource "random_password" "rds_master_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id = aws_secretsmanager_secret.rds_master_password.id
  secret_string = jsonencode({
    username = "masterusername"
    password = random_password.rds_master_password.result
  })
}
