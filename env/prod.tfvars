environment             = "prod"
kms_key_arn             = "arn:aws:kms:us-east-1:891377137882:key/2e241117-1b87-4700-995b-e1ef25b9cd9b"
project                 = "Prod-RDS"
database_identifier     = "prod"
engine                  = "aurora-postgresql"
backup_retention_period = "28"
storage_encrypted       = true
aws_db_subnet_group     = "prod-db-private"
vpc_id                  = "vpc-07744ebbe62ffac58"