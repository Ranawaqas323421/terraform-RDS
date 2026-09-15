variable "db_password" {
  description = "RDS master password"
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
    "subnet-0d402b32f7a163c16",
    "subnet-0478661034104df63"
  ]
}