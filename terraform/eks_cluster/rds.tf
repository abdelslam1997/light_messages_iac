locals {
  db_name     = "djangodb"
  db_username = "djangouser"
  db_port     = "5432"
}

resource "random_password" "db_password" {
  length  = 16
  special = false
  keepers = {
    db_name     = local.db_name
    db_username = local.db_username
  }
}

resource "aws_db_subnet_group" "database" {
  name       = "django-database-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = local.common_tags
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.10.0"

  identifier = "django-postgres-sql"

  engine              = "postgres"
  engine_version      = "16.3"
  family              = "postgres16"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  skip_final_snapshot = true

  db_name  = local.db_name
  username = local.db_username
  port     = local.db_port
  manage_master_user_password = false
  password = random_password.db_password.result

  db_subnet_group_name = aws_db_subnet_group.database.name

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  subnet_ids             = module.vpc.private_subnets

  deletion_protection = false

  # Performance Insights is not free tier eligible
  performance_insights_enabled = false

  # Disable backups to reduce costs
  backup_retention_period = 0

  # Add parameter group settings
  parameters = [
    {
      name  = "client_encoding"
      value = "utf8"
    },
    {
      name  = "rds.force_ssl"
      value = "0"
    },
    {
      name         = "password_encryption"
      value        = "scram-sha-256"
      apply_method = "pending-reboot"
    }
  ]

  tags = local.common_tags

  depends_on = [
    module.vpc,
    aws_security_group.rds_sg
  ]

}

resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS"
  vpc_id      = module.vpc.vpc_id

  # Allow connections from EKS security groups
  ingress {
    from_port = local.db_port
    to_port   = local.db_port
    protocol  = "tcp"
    security_groups = [
      module.eks.node_security_group_id
    ]
  }

  depends_on = [
    module.eks,
  ]
}

#####################################################################
# Create a secret in the Kubernetes cluster with the RDS credentials
#####################################################################

resource "kubernetes_secret" "rds_credentials" {
  metadata {
    name      = "rds-credentials"
    namespace = "default" # Make sure this matches your application's namespace
  }

  data = {
    POSTGRES_DB       = local.db_name
    POSTGRES_USER     = local.db_username
    POSTGRES_PASSWORD = random_password.db_password.result

    POSTGRES_HOST = trimprefix(module.db.db_instance_endpoint, "${module.db.db_instance_identifier}.") # Remove the prefix
    POSTGRES_PORT = local.db_port
    DATABASE_URL  = "postgresql://${local.db_username}:${urlencode(random_password.db_password.result)}@${module.db.db_instance_endpoint}/${local.db_name}"
  }
  depends_on = [module.db]
}