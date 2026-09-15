# DB Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "app-rds-subnet-group"
  description = "Subnet group for MySQL RDS instance"
  subnet_ids  = var.subnet_ids

  tags = {
    Name        = "app-rds-subnet-group"
    Environment = "dev"
    Project     = "RDS-Automation"
  }
}

# Security Group
resource "aws_security_group" "rds_sg" {
  name        = "app-rds-stg"
  description = "Allow MySQL access from application servers"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL access from private network"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "app-rds-stg"
    Environment = "dev"
    Project     = "RDS-Automation"
  }
}

# RDS Instance
resource "aws_db_instance" "mysql" {
  identifier        = "app-mysql-db"
  engine            = "mysql"
  engine_version    = "8.0.46"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "appdb"
  username = local.db_credentials.username
  password = local.db_credentials.password

  multi_az            = true
  publicly_accessible = false

  backup_retention_period = 1

  skip_final_snapshot = true
  deletion_protection = false

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  tags = {
    Name        = "app-mysql-db"
    Environment = "dev"
    Project     = "RDS-Automation"
  }
}