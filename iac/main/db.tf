module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "${var.project}-documents"

  create_db_option_group    = false
  create_db_parameter_group = false

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine               = "mysql"
  engine_version       = "8.0.20"
  family               = "mysql8.0" # DB parameter group
  major_engine_version = "8.0"      # DB option group
  instance_class       = "db.t3.micro"

  allocated_storage = 20

  name                   = var.db_dbname
  username               = var.db_username
  create_random_password = true
  random_password_length = 12
  # password               = var.mysql_password
  port = 3306

  subnet_ids             = module.vpc.public_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]
  publicly_accessible    = true

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 0

  tags = var.tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = "${var.project}-db-documents"
  description = "MySQL security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      #cidr_blocks = module.vpc.vpc_cidr_block
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = var.tags
}