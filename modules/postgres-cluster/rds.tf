#----------------------------------------------Fetch the latest version-------------------------------------------------------------

data "aws_rds_engine_version" "latest_postgres" {
  engine = "postgres"
}

#----------------------------------------Fetch Subnet IDs in the specified VPC-------------------------------------------------------

data "aws_subnets" "example" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = var.aws_db_subnet_group
  subnet_ids  = data.aws_subnets.example.ids
  description = "Subnet group for ${var.environment} RDS instance"
}

#----------------------------------------Fetch the Security Group IDs in the specified VPC-----------------------------------------

data "aws_security_group" "example" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

#----------------------------------------------------- RDS Cluster------------------------------------------------------------------

resource "aws_rds_cluster" "postgres" {
  cluster_identifier      = local.cluster_name
  engine                  = "aurora-postgresql"
  engine_version          = var.engine_version != "" ? var.engine_version : data.aws_rds_engine_version.latest_postgres.version
  database_name           = local.db_name
  master_username         = "masterusername"
  master_password         = random_password.rds_master_password.result
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = true
  storage_encrypted       = var.storage_encrypted
  kms_key_id              = var.kms_key_arn
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [data.aws_security_group.example.id]

  tags = merge(
    local.common_tags,
    var.additional_tags,
    {
      Name = local.cluster_name
    }
  )

  # Enable serverless if the variable is set to true
  engine_mode = var.enable_serverless ? "serverless" : "provisioned"

  # Conditionally create the scaling_configuration block for serverless mode
  dynamic "scaling_configuration" {
    for_each = var.enable_serverless ? [1] : []
    content {
      auto_pause   = true # Enable auto pause
      min_capacity = 2    # Minimum Aurora Capacity Units (ACUs)
      max_capacity = 8    # Maximum Aurora Capacity Units (ACUs)
    }
  }
}

#----------------------------------------------------- RDS Instances------------------------------------------------------------------

# Writer instance (Primary)
resource "aws_rds_cluster_instance" "writer" {
  count                      = var.enable_serverless ? 0 : 1 # Only create this for provisioned clusters
  identifier                 = "${local.cluster_name}-writer"
  cluster_identifier         = aws_rds_cluster.postgres.id
  instance_class             = var.db_instance_class
  engine                     = var.engine
  engine_version             = var.engine_version != "" ? var.engine_version : data.aws_rds_engine_version.latest_postgres.version
  db_subnet_group_name       = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible        = false
  apply_immediately          = true
  auto_minor_version_upgrade = true

  tags = merge(
    local.common_tags,
    var.additional_tags,
    {
      Name = "${local.cluster_name}-writer"
    }
  )
}

# Reader instance (Read replica)
resource "aws_rds_cluster_instance" "read_replica" {
  count                      = var.enable_serverless ? 0 : var.read_replica_count # Only create if not serverless
  identifier                 = "${local.cluster_name}-read-replica-${count.index + 1}"
  cluster_identifier         = aws_rds_cluster.postgres.id
  instance_class             = var.db_instance_class
  engine                     = var.engine
  engine_version             = var.engine_version != "" ? var.engine_version : data.aws_rds_engine_version.latest_postgres.version
  db_subnet_group_name       = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible        = false
  apply_immediately          = true
  auto_minor_version_upgrade = true

  tags = merge(
    local.common_tags,
    var.additional_tags,
    {
      Name = "${local.cluster_name}-read-replica-${count.index + 1}"
    }
  )
}

#-------------------------------------------------locals------------------------------------------------------------

locals {
  is_prod = var.environment == "prod" || var.environment == "demo"

  # Construct the database cluster name
  cluster_prefix = local.is_prod ? "ssawsaur" : "ssnprdaur"
  cluster_name   = "${local.cluster_prefix}-${var.database_identifier}-qorta"

  # Construct the initial database name
  db_name = "${var.database_identifier}qorta${var.environment}"

  # Define common tags
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    # Add other common tags as per your organization's policy
  }
}