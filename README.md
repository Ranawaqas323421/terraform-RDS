# Terraform AWS RDS MySQL Automation

This project provisions a **MySQL RDS instance** on AWS using Terraform, along with the supporting networking resources — a DB subnet group and a security group. It's designed for a dev environment with Multi-AZ enabled for high availability.

## Architecture

- **DB Subnet Group** — spans two subnets inside the target VPC for Multi-AZ deployment
- **Security Group** — allows inbound MySQL traffic (port 3306) and all outbound traffic
- **RDS Instance** — MySQL 8.0, Multi-AZ, private (not publicly accessible)

## Project Structure

```
.
├── provider.tf      # AWS provider configuration
├── variables.tf     # Input variables (password, VPC ID, subnet IDs)
├── main.tf          # Core resources: subnet group, security group, RDS instance
└── README.md
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
- AWS CLI configured with valid credentials (`aws configure`)
- An existing VPC with at least two subnets in different Availability Zones

## Resources Created

| Resource | Name | Description |
|---|---|---|
| `aws_db_subnet_group` | `app-rds-subnet-group` | Subnet group for the RDS instance |
| `aws_security_group` | `app-rds-sg` | Allows MySQL (3306) inbound access |
| `aws_db_instance` | `app-mysql-db` | Multi-AZ MySQL 8.0 instance |

## Variables

| Name | Description | Type | Default |
|---|---|---|---|
| `db_password` | Master password for the RDS instance | `string` | *(required, sensitive)* |
| `vpc_id` | VPC ID where resources are created | `string` | `vpc-0f9febdaf7058a6a6` |
| `subnet_ids` | List of subnet IDs for the DB subnet group | `list(string)` | *(see variables.tf)* |

## Usage

### 1. Clone the repository

```bash
git clone https://github.com/Ranawaqas323421/terraform-RDS.git
cd terraform-RDS
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review the plan

```bash
terraform plan -var="db_password=YourStrongPassword123!"
```

### 4. Apply

```bash
terraform apply -var="db_password=YourStrongPassword123!"
```

Or store your password locally (not committed to git) in a `terraform.tfvars` file:

```hcl
db_password = "YourStrongPassword123!"
```

Then simply run:

```bash
terraform apply
```

### 5. Destroy (when no longer needed)

```bash
terraform destroy -var="db_password=YourStrongPassword123!"
```

## Security Notes

⚠️ **Important considerations for production use:**

- The security group currently allows inbound MySQL access from `0.0.0.0/0` (anywhere). For production, restrict `cidr_blocks` to your application servers' security group or a specific private CIDR range.
- Never commit `terraform.tfvars` or any file containing real passwords to version control. Add it to `.gitignore`.
- Consider enabling `deletion_protection = true` for production databases.
- `skip_final_snapshot = true` means no snapshot is taken on deletion — change this to `false` for production.

## Outputs

After a successful apply, retrieve the RDS endpoint with:

```bash
aws rds describe-db-instances --db-instance-identifier app-mysql-db --query "DBInstances[0].Endpoint.Address" --output text
```

## Author

**Waqas Saleem** — DevOps Engineer
GitHub: [@Ranawaqas323421](https://github.com/Ranawaqas323421)
