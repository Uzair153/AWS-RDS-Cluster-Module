output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_rds_cluster.postgres.endpoint
}

output "db_master_password_secret" {
  description = "The ARN of the master password secret in Secrets Manager"
  value       = aws_secretsmanager_secret.rds_master_password.arn
}


