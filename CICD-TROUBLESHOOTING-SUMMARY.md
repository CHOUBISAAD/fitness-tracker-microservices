# CI/CD Pipeline Troubleshooting Summary

## Problem
All 7 GitHub Actions workflows were failing with credential errors after initial setup.

## Root Causes Identified

### 1. Missing IAM Policies
The IAM user `github-actions-fitness-tracker` was created but didn't have the required permissions attached.

**Error Message:**
```
##[error]Credentials could not be loaded, please check your action inputs: Could not load credentials from any providers
```

### 2. Missing EKS Authentication
The IAM user wasn't added to the EKS cluster's `aws-auth` ConfigMap, preventing Kubernetes access.

## Solutions Applied

### Step 1: Attach ECR Policy
```powershell
aws iam attach-user-policy `
  --user-name github-actions-fitness-tracker `
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser
```

**Purpose:** Allows pushing/pulling Docker images to/from ECR

### Step 2: Attach Custom EKS Policy
```powershell
aws iam put-user-policy `
  --user-name github-actions-fitness-tracker `
  --policy-name EKSDeploymentPolicy `
  --policy-document file://eks-policy.json
```

**Purpose:** Allows describing and accessing EKS cluster

### Step 3: Update EKS aws-auth ConfigMap

**Export current config:**
```powershell
kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth.yaml
```

**Added user mapping:**
```yaml
mapUsers: |
  - userarn: arn:aws:iam::925047941400:user/github-actions-fitness-tracker
    username: github-actions
    groups:
      - system:masters
```

**Apply changes:**
```powershell
kubectl apply -f aws-auth.yaml
```

**Purpose:** Grants GitHub Actions full Kubernetes access (system:masters)

## Verification

### Test Workflow
```powershell
gh workflow run user-service.yml
gh run watch <run-id>
```

### Results
✅ **Workflow Status:** SUCCESS (completed in 4m21s)
✅ **All Steps Passed:**
- Build with Maven
- Configure AWS credentials ← **Previously failing**
- Login to Amazon ECR
- Build and push Docker image
- Update kubeconfig ← **Previously would have failed**
- Deploy to EKS ← **Previously would have failed**
- Verify deployment

### Pod Verification
```powershell
kubectl get pods -n fitness-tracker -l app=user-service
```

**Result:** New pod deployed successfully from CI/CD pipeline (age: 2m35s)

## ECR Repository Status
All required repositories exist:
- fitness-tracker-dev-user-service ✅
- fitness-tracker-dev-activity-service ✅
- fitness-tracker-dev-ai-service ✅
- fitness-tracker-dev-api-gateway ✅
- fitness-tracker-dev-config-server ✅
- fitness-tracker-dev-eureka-server ✅
- fitness-tracker-dev-frontend ✅

## GitHub Secrets Configured
- AWS_ACCESS_KEY_ID ✅
- AWS_SECRET_ACCESS_KEY ✅
- AWS_REGION=eu-west-1 ✅
- ECR_REGISTRY=925047941400.dkr.ecr.eu-west-1.amazonaws.com ✅
- EKS_CLUSTER_NAME=fitness-tracker-dev-eks ✅

## What's Working Now

### Automatic CI/CD Flow
1. **Push to main branch** → Triggers workflow for changed services
2. **Build phase** → Maven/npm build with tests
3. **Docker phase** → Build and push image to ECR with commit SHA tag
4. **Deploy phase** → Update EKS deployment with new image
5. **Verification** → Checks rollout status and pod health

### Smart Configuration Updates
The `config-update.yml` workflow:
- Detects changes in `config-server/src/main/resources/config/`
- Automatically restarts affected services
- Minimizes unnecessary restarts

## Next Steps

1. **Test Other Services** (Optional)
   ```powershell
   gh workflow run activity-service.yml
   gh workflow run frontend.yml
   ```

2. **Make a Code Change** to trigger automatic deployment:
   ```powershell
   # Edit a service file, commit, and push
   git add .
   git commit -m "Test CI/CD pipeline"
   git push
   ```

3. **Monitor Workflows**
   ```powershell
   gh run list --limit 5
   gh run watch <run-id>
   ```

## Troubleshooting Reference

### If workflows still fail:

1. **Check IAM Policies:**
   ```powershell
   aws iam list-attached-user-policies --user-name github-actions-fitness-tracker
   aws iam list-user-policies --user-name github-actions-fitness-tracker
   ```

2. **Verify EKS Auth:**
   ```powershell
   kubectl get configmap aws-auth -n kube-system -o yaml
   ```

3. **Test AWS Credentials:**
   ```powershell
   # Use the same credentials as GitHub Actions
   aws sts get-caller-identity
   aws ecr get-login-password --region eu-west-1
   ```

4. **Check EKS Access:**
   ```powershell
   aws eks update-kubeconfig --name fitness-tracker-dev-eks --region eu-west-1
   kubectl get pods -n fitness-tracker
   ```

## Success Criteria ✅

- [x] IAM user has correct policies
- [x] EKS aws-auth ConfigMap updated
- [x] All ECR repositories exist
- [x] GitHub Secrets configured
- [x] Test workflow completed successfully
- [x] New pod deployed from CI/CD
- [x] All workflow steps passing

## Date Resolved
November 22, 2025

## Time to Resolution
~10 minutes after identifying root causes
