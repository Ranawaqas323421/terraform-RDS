
## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
- AWS CLI configured with valid credentials (`aws configure`) and a default region set (`aws configure set region us-east-1` or `export AWS_DEFAULT_REGION=us-east-1`)
- An existing VPC with at least two subnets in different Availability Zones

## Resources Created

| Resource | Name | Description |
|---|---|---|
| `aws_db_subnet_group` | `app-rds-subnet-group` | Subnet group for the RDS instance |
| `aws_security_group` | `app-rds-sg` | Allows MySQL (3306) inbound access |
| `aws_db_instance` | `app-mysql-db` | Multi-AZ MySQL 8.0 instance |
| `aws_secretsmanager_secret` | `dev/mysql/app` | Container for the DB credentials secret |
| `aws_secretsmanager_secret_version` | — | Stores the actual username/password JSON in the secret |

## Variables

| Name | Description | Type | Default |
|---|---|---|---|
| `db_username` | Master username for the RDS instance | `string` | *(required, sensitive)* |
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

### 3. Set credentials via environment variables (recommended — never committed to git)

```bash
export TF_VAR_db_username="admin"
export TF_VAR_db_password="YourStrongPassword123!"
```

### 4. Review the plan

```bash
terraform plan
```

### 5. Apply

```bash
terraform apply
```

Or store your credentials locally (not committed to git) in a `terraform.tfvars` file instead of environment variables:

```hcl
db_username = "admin"
db_password = "YourStrongPassword123!"
```

### 6. Destroy (when no longer needed)

```bash
terraform destroy
```

## Handling Pre-Existing AWS Resources

If a resource (e.g. the security group or the Secrets Manager secret) was already created outside Terraform — manually via the CLI/Console, or from a previous partial apply — Terraform will fail with a `Duplicate` / `ResourceExistsException` error instead of creating it again. Import the existing resource into Terraform's state first:

```bash
# Security Group
aws ec2 describe-security-groups --filters "Name=group-name,Values=app-rds-sg" "Name=vpc-id,Values=<vpc-id>" --query 'SecurityGroups[*].GroupId' --output text
terraform import aws_security_group.rds_sg <SG_ID>

# Secrets Manager Secret (requires the full ARN, not just the name)
aws secretsmanager describe-secret --secret-id dev/mysql/app --region us-east-1 --query 'ARN' --output text
terraform import aws_secretsmanager_secret.rds_credentials "<full-secret-arn>"

# Secrets Manager Secret Version (requires the VersionId)
aws secretsmanager get-secret-value --secret-id dev/mysql/app --region us-east-1 --query 'VersionId' --output text
terraform import aws_secretsmanager_secret_version.rds_credentials_version "dev/mysql/app|<VersionId>"
```

After importing, run `terraform plan` to confirm there's no unexpected drift, then `terraform apply` as usual.

## Security Notes

⚠️ **Important considerations for production use:**

- The security group currently allows inbound MySQL access from `0.0.0.0/0` (anywhere). For production, restrict `cidr_blocks` to your application servers' security group or a specific private CIDR range.
- Never commit `terraform.tfvars` or any file containing real credentials to version control. Add it to `.gitignore`.
- Database credentials are never hardcoded in `.tf` files — they flow entirely through `var.db_username` / `var.db_password`, sourced from environment variables or a git-ignored `terraform.tfvars`.
- Consider enabling `deletion_protection = true` for production databases.
- `skip_final_snapshot = true` means no snapshot is taken on deletion — change this to `false` for production.

## Outputs

After a successful apply, retrieve the RDS endpoint with:

```bash
aws rds describe-db-instances --db-instance-identifier app-mysql-db --query "DBInstances[0].Endpoint.Address" --output text
```

Retrieve the stored credentials from Secrets Manager with:

```bash
aws secretsmanager get-secret-value --secret-id dev/mysql/app --region us-east-1 --query 'SecretString' --output text
```

## Author

**Waqas Saleem** — DevOps Engineer
GitHub: [@Ranawaqas323421](https://github.com/Ranawaqas323421)
