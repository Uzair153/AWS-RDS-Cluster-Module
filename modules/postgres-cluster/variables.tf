variable "environment" {
  description = "The environment for the RDS instance (e.g., prod, nonprod)"
  type        = string
}

variable "db_instance_class" {
  description = "The instance class to use"
  default     = "db.t3.medium"
}


variable "kms_key_arn" {
  description = "The KMS key for encryption at rest"
  type        = string
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "database_identifier" {
  type        = string
  description = "Unique identifier for the database"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags to apply to resources"
  default     = {}
}

variable "engine" {
  type        = string
  description = "Our rds Engine"
}

variable "backup_retention_period" {
  type        = string
  description = "backup_retention_period"
}

variable "storage_encrypted" {
  type        = bool
  description = "storage_encrypted"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the RDS instance will be deployed."
}

variable "aws_db_subnet_group" {
  type        = string
  description = "Subnet Group name for Demo/prod and nonprod."
}

variable "read_replica_count" {
  description = "The number of read replicas to create for the RDS cluster"
  type        = number
  default     = 0
}

variable "engine_version" {
  description = "The version of the RDS engine. Default is the latest available Postgres version."
  type        = string
  default     = "13.12"
}

# Define variable for serverless configuration
variable "enable_serverless" {
  description = "Enable Aurora Serverless"
  type        = bool
  default     = false # Set to true to enable serverless
}