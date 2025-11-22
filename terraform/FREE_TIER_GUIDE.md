# AWS Free Tier Constraints & Cost Optimization

## Your Available EC2 Instance Types

Based on your free trial account, you have access to:
- ✅ **t3.micro** (1 vCPU, 1GB RAM) - 750 hours/month FREE
- ✅ **t3.small** (2 vCPU, 2GB RAM) - Partially eligible for free tier
- ✅ **c7i-flex.large** (2 vCPU, 4GB RAM) - NOT free tier
- ✅ **m7i-flex.large** (2 vCPU, 8GB RAM) - NOT free tier

## Configuration Decisions

### EKS Nodes: t3.small (BEST CHOICE)

**Why not t3.micro?**
- Kubernetes requires minimum 2GB RAM per node
- t3.micro (1GB RAM) is **too small** to run Kubernetes pods
- kubelet + system pods consume ~600-800MB alone

**Why t3.small?**
- ✅ 2 vCPU, 2GB RAM - sufficient for small microservices
- ✅ Cheapest option that meets K8s requirements
- ✅ Partially eligible for free tier credits (750 hours EC2 free tier applies)
- ✅ Can run 3-4 lightweight pods per node

**Why not c7i-flex.large or m7i-flex.large?**
- ❌ More expensive (~$0.10-0.15/hour vs $0.0208/hour)
- ❌ NOT free tier eligible
- ❌ Overkill for this application (4-8GB RAM not needed)

**Configuration**:
```hcl
eks_node_instance_type = "t3.small"
eks_desired_capacity   = 2  # Minimum for HA
eks_min_capacity       = 2
eks_max_capacity       = 2  # Fixed to control costs
```

### RDS PostgreSQL: db.t3.micro (FREE)

**Free Tier Benefits**:
- ✅ **750 hours/month FREE** (first 12 months)
- ✅ **20GB SSD storage FREE**
- ✅ **1GB backup storage FREE**
- ✅ Sufficient for User Service database

**Configuration**:
```hcl
rds_instance_class    = "db.t3.micro"
rds_allocated_storage = 20  # Max free tier
backup_retention_period = 1  # Minimize backup costs
```

### DocumentDB: db.t3.medium (NOT FREE)

**Why it costs money**:
- ❌ DocumentDB is NOT included in free tier
- ❌ Minimum instance is db.t3.medium (~$0.10/hour = $70/month)
- ❌ No free tier equivalent for MongoDB-compatible service

**Cost Optimization Options**:
1. **Keep DocumentDB** (~$70/month) - Simplest, managed service
2. **Self-host MongoDB on EKS** - FREE but requires more setup
3. **Use RDS PostgreSQL for all data** - Use JSONB columns for Activity/AI data

**Recommendation**: Self-host MongoDB on EKS to avoid $70/month cost.

### Amazon MQ RabbitMQ: mq.t3.micro (NOT FREE)

**Why it costs money**:
- ❌ Amazon MQ is NOT included in free tier
- ❌ mq.t3.micro costs ~$40/month
- ❌ No free tier equivalent

**Cost Optimization Options**:
1. **Keep Amazon MQ** (~$40/month) - Managed, reliable
2. **Self-host RabbitMQ on EKS** - FREE but requires setup
3. **Use AWS SQS** - Pay per request (free tier: 1M requests/month)

**Recommendation**: Self-host RabbitMQ on EKS to avoid $40/month cost.

## Cost Breakdown

### Option 1: Current Configuration (Managed Services)

| Service | Cost | Free Tier |
|---------|------|-----------|
| EKS Control Plane | $72/month | ❌ NOT FREE |
| 2x t3.small nodes (730 hrs) | ~$30/month | ✅ Partial (750 hrs free EC2) |
| RDS db.t3.micro | **FREE** | ✅ 750 hrs/month |
| DocumentDB db.t3.medium | $70/month | ❌ NOT FREE |
| Amazon MQ mq.t3.micro | $40/month | ❌ NOT FREE |
| NAT Gateways (2) | $64/month | ❌ NOT FREE |
| Data Transfer | ~$10/month | ✅ 100GB free |
| **TOTAL** | **~$286/month** | |

### Option 2: Self-Host MongoDB + RabbitMQ (RECOMMENDED)

| Service | Cost | Free Tier |
|---------|------|-----------|
| EKS Control Plane | $72/month | ❌ NOT FREE |
| 2x t3.small nodes | ~$30/month | ✅ Partial |
| RDS db.t3.micro | **FREE** | ✅ 750 hrs/month |
| ~~DocumentDB~~ (Self-hosted) | **$0** | ✅ Runs on EKS |
| ~~Amazon MQ~~ (Self-hosted) | **$0** | ✅ Runs on EKS |
| NAT Gateways (2) | $64/month | ❌ NOT FREE |
| Data Transfer | ~$10/month | ✅ 100GB free |
| **TOTAL** | **~$176/month** | **$110/month saved** |

### Option 3: Remove NAT Gateways (CHEAPEST but less secure)

| Service | Cost | Free Tier |
|---------|------|-----------|
| EKS Control Plane | $72/month | ❌ NOT FREE |
| 2x t3.small nodes | ~$30/month | ✅ Partial |
| RDS db.t3.micro | **FREE** | ✅ 750 hrs/month |
| Self-hosted MongoDB | **$0** | ✅ Runs on EKS |
| Self-hosted RabbitMQ | **$0** | ✅ Runs on EKS |
| ~~NAT Gateways~~ (Use public subnets) | **$0** | ⚠️ Less secure |
| Data Transfer | ~$10/month | ✅ 100GB free |
| **TOTAL** | **~$112/month** | **$174/month saved** |

**⚠️ Warning**: Running EKS nodes in public subnets is less secure. Suitable for testing only.

## AWS Free Tier Limits (12 Months)

### Compute
- ✅ **750 hours/month** EC2 t2.micro or t3.micro (Linux)
- ✅ **750 hours/month** EC2 t2.micro or t3.micro (Windows)
- ❌ EKS control plane NOT free ($0.10/hour = $72/month)

### Database
- ✅ **750 hours/month** RDS db.t2.micro or db.t3.micro
- ✅ **20GB SSD storage** (General Purpose SSD)
- ✅ **20GB backup storage**
- ❌ DocumentDB NOT included

### Storage
- ✅ **5GB S3 standard storage**
- ✅ **20,000 Get requests**, 2,000 Put requests
- ✅ **30GB EBS storage** (General Purpose SSD)

### Networking
- ✅ **100GB data transfer OUT** per month
- ✅ **1GB data transfer OUT to internet** (CloudFront)
- ❌ NAT Gateway NOT free ($0.045/hour + $0.045/GB)

### Container Registry
- ✅ **500MB ECR storage** per month
- ❌ Additional storage $0.10/GB/month

### Message Queue
- ✅ **1 million SQS requests** per month
- ❌ Amazon MQ NOT free

## Recommendations for Your Free Trial

### Immediate Actions

1. **Keep current Terraform config** - t3.small is the right choice for EKS
2. **Self-host MongoDB and RabbitMQ** instead of DocumentDB/Amazon MQ
3. **Consider removing NAT Gateways** for testing (use public subnets)

### Self-Hosted Services on EKS

You can deploy these as StatefulSets/Deployments:

**MongoDB** (replaces DocumentDB):
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb
spec:
  serviceName: mongodb
  replicas: 1
  template:
    spec:
      containers:
      - name: mongodb
        image: mongo:7
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
```

**RabbitMQ** (replaces Amazon MQ):
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: rabbitmq
spec:
  serviceName: rabbitmq
  replicas: 1
  template:
    spec:
      containers:
      - name: rabbitmq
        image: rabbitmq:3.13-management
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
```

**Keycloak** (OAuth server):
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: keycloak
spec:
  serviceName: keycloak
  replicas: 1
  template:
    spec:
      containers:
      - name: keycloak
        image: quay.io/keycloak/keycloak:23.0
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
```

### Resource Allocation per t3.small Node (2GB RAM)

**Node Capacity**: 2GB RAM, 2 vCPU

**System Overhead**: ~600MB RAM
- kubelet: ~200MB
- kube-proxy: ~100MB
- Container runtime: ~150MB
- OS: ~150MB

**Available for Pods**: ~1400MB RAM per node

**Pod Distribution (2 nodes total)**:
```
Node 1:
- Keycloak: 512MB
- User Service: 256MB
- Activity Service: 256MB
- API Gateway: 256MB
Available: ~120MB

Node 2:
- RabbitMQ: 256MB
- MongoDB: 256MB
- AI Service: 256MB
- Frontend (Nginx): 128MB
- Config Server: 256MB
- Eureka: 256MB
Available: ~192MB
```

This is **tight but workable** for testing. Production would need t3.medium or larger.

## Modified Terraform Modules Needed

If self-hosting MongoDB and RabbitMQ, you can **remove** these modules:
- `terraform/modules/documentdb/` - Not needed
- `terraform/modules/mq/` - Not needed

And update `main.tf`:
```hcl
# Comment out or remove:
# module "documentdb" { ... }
# module "mq" { ... }
```

## Next Steps

1. **Decide on cost vs. convenience**:
   - Option 1: Use current config ($286/month) - Everything managed
   - Option 2: Self-host MongoDB + RabbitMQ ($176/month) - Save $110/month
   - Option 3: Public subnets ($112/month) - Save $174/month, less secure

2. **If choosing Option 2 or 3**, I can:
   - Update Terraform to remove DocumentDB/MQ modules
   - Create K8s manifests for self-hosted MongoDB/RabbitMQ
   - Update application configs to use in-cluster services

3. **Apply Terraform** with current budget-optimized configuration

Which option do you prefer? I recommend **Option 2** (self-host MongoDB + RabbitMQ) for best balance of cost and security.
