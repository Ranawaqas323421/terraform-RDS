variable "db_password" {
  description = "Password for RDS MySQL instance"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
  default     = "vpc-0f9febdaf7058a6a6"
}

variable "subnet_ids" {
  description = "Subnet IDs for the DB subnet group"
  type        = list(string)
  default = [
    "subnet-005d4953d9734f867",
    "subnet-0db13bfc832d33ece"
  ]
}