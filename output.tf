#------------------------Outputs---------------------

output "postgres_instance_endpoint" {
  value = module.postgres-cluster.db_instance_endpoint
}

output "postgres_master_password_secret" {
  value = module.postgres-cluster.db_master_password_secret
}

