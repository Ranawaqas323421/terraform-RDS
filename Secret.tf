# Secret container
resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "dev/mysql/app"
  description = "Credentials for MySQL RDS Instance"
}

# Secret value (actual username/password JSON)
resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = "admin"
    password = var.db_password
  })
}

# Read the secret back (agar RDS instance isi se password lena ho)
locals {
  db_credentials = jsondecode(aws_secretsmanager_secret_version.rds_credentials_version.secret_string)
}