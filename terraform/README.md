# Terraform AWS Infrastructure

This directory contains Terraform configurations to deploy the microservices fitness tracker application to AWS EKS.

## Architecture Overview

The infrastructure includes:
- **VPC**: Custom VPC with public and private subnets across 2 availability zones
- **EKS**: Kubernetes cluster with managed node group (2 t3.small nodes - free tier eligible)
- **ECR**: Container registries for all 7 microservices
- **RDS PostgreSQL**: Database for User Service (db.t3.micro, 20GB - FREE in free tier)
- **DocumentDB**: MongoDB-compatible database for Activity and AI Services (db.t3.medium)
- **Amazon MQ**: Managed RabbitMQ broker (mq.t3.micro)

**Region**: eu-west-1 (Ireland - closest to Morocco)

## Cost Optimization

This setup is optimized for cost-efficiency and temporary usage:
- **Free tier eligible instances**: t3.small for EKS nodes, db.t3.micro for RDS
- **Minimal node count**: 2 nodes (required minimum for HA)
- **Single-instance deployment** for databases
- **Easy teardown** with `terraform destroy`

**⚠️ Important Free Tier Constraints**:
- EC2 instance types available: t3.micro, t3.small, c7i-flex.large, m7i-flex.large
- **t3.micro too small for Kubernetes** (minimum 2GB RAM required per node)
- Using **t3.small** (2 vCPU, 2GB RAM) - partially free tier eligible
- RDS db.t3.micro is **FULLY FREE** (750 hours/month for 12 months)

**Estimated Cost**: ~$286/month with free tier applied (first 12 months)
- RDS db.t3.micro: FREE (750 hours/month)
- EC2 t3.small: ~$15/month after free tier credit
- EKS control plane: $72/month (NOT free tier eligible)
- NAT Gateways: $64/month (required for private subnets)

## Prerequisites

1. **AWS CLI**: Installed and configured
   ```powershell
   aws --version
   aws configure
   ```

2. **Terraform**: Version 1.0 or higher
   ```powershell
   terraform version
   ```

3. **kubectl**: For EKS cluster management
   ```powershell
   kubectl version --client
   ```

4. **AWS Credentials**: Ensure your AWS account has appropriate permissions:
   - EC2, VPC, EKS
   - RDS, DocumentDB
   - Amazon MQ, ECR
   - IAM role creation

## Quick Start

### 1. Initialize Terraform

```powershell
cd c:\microApp\terraform
terraform init
```

This downloads provider plugins (AWS, Kubernetes, Helm).

### 2. Review Configuration

Edit `variables.tf` if you need to customize:
- Region (default: eu-west-1)
- Instance types
- Cluster size
- Database specs

### 3. Validate Configuration

```powershell
terraform validate
```

### 4. Preview Changes

```powershell
terraform plan
```

Review the resources that will be created (~50 resources).

### 5. Apply Infrastructure

```powershell
terraform apply
```

Type `yes` when prompted. This takes **15-20 minutes**.

### 6. Configure kubectl

After successful apply, configure kubectl to access your cluster:

```powershell
aws eks update-kubeconfig --region eu-west-1 --name microapp-prod-eks
```

Verify connection:
```powershell
kubectl get nodes
```

### 7. Get Outputs

Retrieve important values:

```powershell
# EKS cluster endpoint
terraform output cluster_endpoint

# ECR repository URLs
terraform output ecr_repositories

# Database endpoints (sensitive)
terraform output -json rds_endpoint
terraform output -json documentdb_endpoint
terraform output -json mq_amqp_endpoint

# Database credentials (sensitive)
terraform output -json rds_master_username
terraform output -json rds_master_password
terraform output -json documentdb_master_username
terraform output -json documentdb_master_password
terraform output -json mq_admin_username
terraform output -json mq_admin_password
```

## Module Structure

```
terraform/
├── main.tf              # Root configuration, module orchestration
├── variables.tf         # Input variables with defaults
├── outputs.tf           # Output values
└── modules/
    ├── vpc/            # VPC with subnets, NAT, IGW
    ├── eks/            # EKS cluster and node group
    ├── ecr/            # Container registries
    ├── rds/            # PostgreSQL database
    ├── documentdb/     # MongoDB-compatible database
    └── mq/             # RabbitMQ message broker
```

Each module contains:
- `main.tf`: Resource definitions
- `variables.tf`: Input parameters
- `outputs.tf`: Exported values

## Security Features

- **Encryption**: All storage encrypted (RDS, DocumentDB, ECR)
- **Private Subnets**: Databases and EKS nodes in private subnets
- **Security Groups**: Least-privilege access rules
- **IAM Roles**: Service-specific permissions
- **Random Passwords**: Auto-generated for databases/brokers
- **TLS**: All connections encrypted in transit

## Next Steps After Apply

1. **Push Docker images to ECR**:
   ```powershell
   # Authenticate to ECR
   aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-west-1.amazonaws.com
   
   # Tag and push each service
   docker tag microapp-eureka-server:latest <ecr-url>/microapp-prod-eureka-server:latest
   docker push <ecr-url>/microapp-prod-eureka-server:latest
   ```

2. **Create Kubernetes manifests** (Deployments, Services, ConfigMaps, Secrets, Ingress)

3. **Deploy to EKS**:
   ```powershell
   kubectl apply -f k8s/
   ```

4. **Setup Jenkins CI/CD pipeline** for automated deployments

5. **Migrate databases** from local to RDS/DocumentDB

## Cleanup

When done testing, destroy all resources to avoid charges:

```powershell
terraform destroy
```

Type `yes` when prompted. This takes ~10-15 minutes.

**Important**: This permanently deletes all resources. Ensure you've backed up any important data.

## Troubleshooting

### Issue: Terraform init fails
- **Solution**: Check internet connectivity, verify Terraform version

### Issue: Authentication errors
- **Solution**: Run `aws configure` and verify credentials with `aws sts get-caller-identity`

### Issue: Resource quota errors
- **Solution**: Check AWS service quotas, may need to request increases

### Issue: EKS node group fails
- **Solution**: Verify NAT gateways are running (nodes need internet access for ECR pulls)

### Issue: kubectl can't connect
- **Solution**: Re-run `aws eks update-kubeconfig` command from outputs

## State Management

Terraform state is stored locally in `terraform.tfstate`. For team collaboration, consider:
- **S3 Backend**: Store state in S3 bucket
- **DynamoDB**: State locking to prevent conflicts
- **Remote Backend**: Terraform Cloud or GitLab

Example backend configuration:
```hcl
terraform {
  backend "s3" {
    bucket = "microapp-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = "microapp-terraform-locks"
  }
}
```

## Variables Reference

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | eu-west-1 |
| `project_name` | Project name for tagging | microapp |
| `environment` | Environment name | prod |
| `eks_cluster_version` | Kubernetes version | 1.28 |
| `eks_node_instance_type` | EKS node instance type | **t3.small** (free tier) |
| `eks_desired_capacity` | Desired node count | 2 |
| `eks_min_capacity` | Minimum node count | 2 |
| `eks_max_capacity` | Maximum node count | 2 |
| `rds_instance_class` | RDS instance type | **db.t3.micro** (FREE) |
| `rds_allocated_storage` | RDS storage (GB) | 20 (FREE) |
| `docdb_instance_class` | DocumentDB instance type | db.t3.medium |
| `docdb_instance_count` | DocumentDB instance count | 1 |
| `mq_instance_type` | Amazon MQ instance type | mq.t3.micro |

## Support

For issues or questions:
1. Check AWS CloudWatch logs
2. Review Terraform state: `terraform show`
3. Verify AWS console for resource status
4. Check security group rules if connectivity fails

## License

This infrastructure code is part of the microservices fitness tracker project.
