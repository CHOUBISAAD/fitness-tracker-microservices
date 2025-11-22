# AWS Infrastructure Setup - Phase 2 Complete

## Summary

All Terraform configurations for AWS EKS deployment have been created successfully.

## Created Files (26 total)

### Root Configuration (4 files)
- ✅ `terraform/main.tf` - Root module orchestration, provider configuration
- ✅ `terraform/variables.tf` - All input variables with budget-conscious defaults
- ✅ `terraform/outputs.tf` - Output values for cluster, databases, ECR URLs
- ✅ `terraform/.gitignore` - Terraform-specific ignore rules

### VPC Module (3 files)
- ✅ `terraform/modules/vpc/main.tf` - VPC, subnets, NAT, IGW, route tables
- ✅ `terraform/modules/vpc/variables.tf` - VPC input parameters
- ✅ `terraform/modules/vpc/outputs.tf` - VPC resource IDs

### EKS Module (3 files)
- ✅ `terraform/modules/eks/main.tf` - EKS cluster, node group, IAM roles, security groups
- ✅ `terraform/modules/eks/variables.tf` - EKS input parameters
- ✅ `terraform/modules/eks/outputs.tf` - Cluster endpoint, kubectl config

### ECR Module (3 files)
- ✅ `terraform/modules/ecr/main.tf` - 7 ECR repositories with lifecycle policies
- ✅ `terraform/modules/ecr/variables.tf` - ECR input parameters
- ✅ `terraform/modules/ecr/outputs.tf` - Repository URLs and ARNs

### RDS Module (3 files)
- ✅ `terraform/modules/rds/main.tf` - PostgreSQL database, security group
- ✅ `terraform/modules/rds/variables.tf` - RDS input parameters
- ✅ `terraform/modules/rds/outputs.tf` - Database endpoint, credentials

### DocumentDB Module (3 files)
- ✅ `terraform/modules/documentdb/main.tf` - MongoDB-compatible cluster, security group
- ✅ `terraform/modules/documentdb/variables.tf` - DocumentDB input parameters
- ✅ `terraform/modules/documentdb/outputs.tf` - Cluster endpoint, credentials

### Amazon MQ Module (3 files)
- ✅ `terraform/modules/mq/main.tf` - RabbitMQ broker, security group
- ✅ `terraform/modules/mq/variables.tf` - MQ input parameters
- ✅ `terraform/modules/mq/outputs.tf` - Broker endpoint, credentials

### Documentation (1 file)
- ✅ `terraform/README.md` - Comprehensive setup guide, troubleshooting

## Infrastructure Resources

### Networking (VPC Module)
- 1 VPC (10.0.0.0/16)
- 2 Public Subnets (10.0.1.0/24, 10.0.2.0/24)
- 2 Private Subnets (10.0.3.0/24, 10.0.4.0/24)
- 1 Internet Gateway
- 2 NAT Gateways (with Elastic IPs)
- 3 Route Tables (1 public, 2 private)

### Compute (EKS Module)
- 1 EKS Cluster (Kubernetes 1.28)
- 1 Managed Node Group (2 t3.small nodes - free tier eligible)
- 2 IAM Roles (cluster + nodes)
- 2 Security Groups (cluster + nodes)
- 1 OIDC Provider (for IAM roles for service accounts)

### Container Registry (ECR Module)
- 7 ECR Repositories:
  - microapp-prod-eureka-server
  - microapp-prod-config-server
  - microapp-prod-api-gateway
  - microapp-prod-userservice
  - microapp-prod-activityservice
  - microapp-prod-aiservice
  - microapp-prod-fitness-front
- Lifecycle policies (keep last 10 images)
- Scan on push enabled

### Databases (RDS Module)
- 1 PostgreSQL Instance (db.t3.micro)
  - Engine version: 16.1
  - Storage: 20GB gp3 encrypted
  - Automated backups (7 days)
  - CloudWatch logs enabled
- 1 Security Group (port 5432)
- 1 DB Subnet Group
- Random password generation

### Databases (DocumentDB Module)
- 1 DocumentDB Cluster (MongoDB 5.0 compatible)
  - 1 Instance (db.t3.medium)
  - Automated backups (7 days)
  - CloudWatch logs enabled
  - TLS enabled
- 1 Security Group (port 27017)
- 1 DB Subnet Group
- Random password generation

### Message Broker (MQ Module)
- 1 Amazon MQ Broker (RabbitMQ 3.11)
  - Instance type: mq.t3.micro
  - Single-instance deployment
  - General logs enabled
  - Private subnet placement
- 1 Security Group (ports 5671, 443)
- Random password generation

## Configuration Defaults

```hcl
Region:                eu-west-1 (Ireland)
Project:               microapp
Environment:           prod

EKS:
  Cluster Version:     1.28
  Node Type:           t3.small (free tier eligible)
  Desired Nodes:       2
  Min Nodes:           2
  Max Nodes:           2

RDS PostgreSQL:
  Instance Class:      db.t3.micro
  Engine:              16.1
  Storage:             20GB gp3
  Backup Retention:    7 days

DocumentDB:
  Instance Class:      db.t3.medium
  Engine:              5.0
  Instance Count:      1
  Backup Retention:    7 days

Amazon MQ:
  Instance Type:       mq.t3.micro
  Engine:              RabbitMQ 3.11
  Deployment:          SINGLE_INSTANCE
```

## Security Features

✅ **Encryption at Rest**
- RDS: storage_encrypted = true
- DocumentDB: storage_encrypted = true
- ECR: AES256 encryption

✅ **Encryption in Transit**
- All connections use TLS/SSL
- Amazon MQ: AMQPS (port 5671)
- RDS/DocumentDB: SSL connections enforced

✅ **Network Security**
- Databases in private subnets
- EKS nodes in private subnets
- NAT gateways for outbound traffic
- Security groups with least-privilege rules

✅ **IAM Security**
- Service-specific IAM roles
- EKS OIDC provider for pod identities
- ECR repository policies

✅ **Secret Management**
- Random password generation (16 chars)
- Sensitive outputs marked as sensitive
- No hardcoded credentials

## Cost Estimate

**Monthly Costs (approximation)**:
- EKS Cluster: $72/month ($0.10/hour)
- 2x t3.small nodes: ~$30/month (750 hours free tier for 12 months)
- RDS db.t3.micro: FREE (750 hours/month for 12 months)
- DocumentDB db.t3.medium: ~$70/month (NOT free tier)
- Amazon MQ mq.t3.micro: ~$40/month (NOT free tier)
- NAT Gateways: ~$64/month (2x $32)
- Data transfer: ~$10/month

**Total: ~$286/month** (with free tier applied for first 12 months)

**Free Tier Eligible Resources**:
- 750 hours/month EC2 t2.micro/t3.micro (first 12 months) - t3.small partially eligible
- 750 hours/month RDS db.t3.micro (first 12 months) - FULLY FREE
- 20GB RDS SSD storage - FULLY FREE
- 1GB RDS backups - FULLY FREE
- EKS NOT free ($72/month for cluster control plane)

## Next Steps

### Step 1: Validate Configuration
```powershell
cd c:\microApp\terraform
terraform init
terraform validate
```

### Step 2: Review Plan
```powershell
terraform plan
```
Review the ~50 resources that will be created.

### Step 3: Apply Infrastructure
```powershell
terraform apply
```
Type `yes` when prompted. **Takes 15-20 minutes**.

### Step 4: Configure kubectl
```powershell
aws eks update-kubeconfig --region eu-west-1 --name microapp-prod-eks
kubectl get nodes
```

### Step 5: Get Database Credentials
```powershell
# RDS
terraform output rds_endpoint
terraform output -json rds_master_username
terraform output -json rds_master_password

# DocumentDB
terraform output documentdb_endpoint
terraform output -json documentdb_master_username
terraform output -json documentdb_master_password

# Amazon MQ
terraform output mq_amqp_endpoint
terraform output -json mq_admin_username
terraform output -json mq_admin_password
```

### Step 6: Push Docker Images to ECR
```powershell
# Get ECR URLs
terraform output ecr_repositories

# Authenticate
$ACCOUNT_ID = (aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com"

# Tag and push each service
docker tag microapp-eureka-server:latest "$ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/microapp-prod-eureka-server:latest"
docker push "$ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/microapp-prod-eureka-server:latest"

# Repeat for all 7 services
```

## Upcoming Phases

### Phase 3: Kubernetes Manifests
- Create Deployment manifests for all services
- Create Service resources (ClusterIP, LoadBalancer)
- Create ConfigMaps for application configuration
- Create Secrets for database credentials
- Create Ingress/ALB for external access
- Create HorizontalPodAutoscaler for scaling
- Create Keycloak StatefulSet

### Phase 4: Jenkins CI/CD Pipeline
- Setup Jenkins server (EC2 or EKS)
- Create Jenkinsfile with build stages
- Configure AWS credentials in Jenkins
- Setup GitHub webhook for automated builds
- Implement automated testing
- Configure deployment to EKS
- Setup rollback mechanism

### Phase 5: Database Migration
- Export data from local PostgreSQL
- Export data from local MongoDB
- Import to RDS PostgreSQL
- Import to DocumentDB
- Update connection strings in K8s ConfigMaps
- Test connectivity from pods

## Troubleshooting

### If terraform init fails:
```powershell
# Check Terraform version
terraform version

# Clean and retry
Remove-Item -Recurse -Force .terraform
terraform init
```

### If terraform apply fails:
```powershell
# Check AWS credentials
aws sts get-caller-identity

# Check quotas
aws service-quotas list-service-quotas --service-code eks

# Enable detailed logging
$env:TF_LOG="DEBUG"
terraform apply
```

### If kubectl can't connect:
```powershell
# Verify EKS cluster exists
aws eks describe-cluster --name microapp-prod-eks --region eu-west-1

# Re-configure kubectl
aws eks update-kubeconfig --region eu-west-1 --name microapp-prod-eks --kubeconfig ~/.kube/config

# Test connection
kubectl cluster-info
```

## Cleanup Instructions

When testing is complete, destroy all resources:

```powershell
cd c:\microApp\terraform
terraform destroy
```

Type `yes` when prompted. **Takes 10-15 minutes**.

**Warning**: This permanently deletes:
- EKS cluster and nodes
- All databases (RDS, DocumentDB)
- Amazon MQ broker
- ECR repositories and images
- VPC and networking resources

Ensure you have backups of any important data before destroying.

## Files Created in This Session

Total: 26 files
- Root: 4 files (main.tf, variables.tf, outputs.tf, .gitignore)
- VPC module: 3 files
- EKS module: 3 files
- ECR module: 3 files
- RDS module: 3 files
- DocumentDB module: 3 files
- MQ module: 3 files
- Documentation: 2 files (README.md, INFRASTRUCTURE_SUMMARY.md)

**Phase 2: AWS Infrastructure Setup - COMPLETE ✅**
