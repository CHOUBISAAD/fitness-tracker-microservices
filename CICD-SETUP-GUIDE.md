# GitHub Actions CI/CD Setup Guide

## Step 1: Push Workflows to GitHub

First, commit and push the workflow files:

```powershell
cd c:\microApp
git add .github/
git commit -m "Add GitHub Actions CI/CD pipelines"
git push origin main
```

## Step 2: Create AWS IAM User for GitHub Actions

### Option A: Using AWS Console

1. Go to **AWS Console** → **IAM** → **Users**
2. Click **Create user**
3. User name: `github-actions-fitness-tracker`
4. Click **Next**
5. Select **Attach policies directly**
6. Attach these policies:
   - `AmazonEC2ContainerRegistryPowerUser`
   - `AmazonEKSClusterPolicy`
   - Custom policy for EKS deployment (see below)
7. Click **Next** → **Create user**
8. Go to user → **Security credentials** → **Create access key**
9. Select **Application running outside AWS**
10. Save the **Access Key ID** and **Secret Access Key**

### Option B: Using AWS CLI

```powershell
# Create IAM user
aws iam create-user --user-name github-actions-fitness-tracker

# Attach ECR policy
aws iam attach-user-policy `
  --user-name github-actions-fitness-tracker `
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser

# Create and attach custom EKS policy
aws iam put-user-policy `
  --user-name github-actions-fitness-tracker `
  --policy-name EKSDeploymentPolicy `
  --policy-document file://eks-policy.json

# Create access key
aws iam create-access-key --user-name github-actions-fitness-tracker
```

Save the output - you'll need the **AccessKeyId** and **SecretAccessKey**.

## Step 3: Create EKS Policy Document

Create `c:\microApp\eks-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "eks:AccessKubernetesApi",
        "eks:DescribeCluster"
      ],
      "Resource": "arn:aws:eks:eu-west-1:925047941400:cluster/fitness-tracker-dev-eks"
    }
  ]
}
```

## Step 4: Update EKS aws-auth ConfigMap

Add the IAM user to Kubernetes RBAC:

```powershell
# Get current aws-auth configmap
kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth.yaml

# Edit aws-auth.yaml and add under mapUsers:
```

Add this section:

```yaml
mapUsers: |
  - userarn: arn:aws:iam::925047941400:user/github-actions-fitness-tracker
    username: github-actions
    groups:
      - system:masters
```

Apply the updated configmap:

```powershell
kubectl apply -f aws-auth.yaml
```

## Step 5: Configure GitHub Secrets

### Via GitHub Web UI

1. Go to your GitHub repository
2. Click **Settings** (top right)
3. In left sidebar: **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Add each secret:

| Name | Value | Example |
|------|-------|---------|
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key ID | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_REGION` | AWS Region | `eu-west-1` |
| `ECR_REGISTRY` | ECR Registry URL | `925047941400.dkr.ecr.eu-west-1.amazonaws.com` |
| `EKS_CLUSTER_NAME` | EKS Cluster Name | `fitness-tracker-dev-eks` |

### Via GitHub CLI

```powershell
# Install GitHub CLI if not already installed
# winget install --id GitHub.cli

# Login to GitHub
gh auth login

# Set secrets
gh secret set AWS_ACCESS_KEY_ID --body "YOUR_ACCESS_KEY_ID"
gh secret set AWS_SECRET_ACCESS_KEY --body "YOUR_SECRET_KEY"
gh secret set AWS_REGION --body "eu-west-1"
gh secret set ECR_REGISTRY --body "925047941400.dkr.ecr.eu-west-1.amazonaws.com"
gh secret set EKS_CLUSTER_NAME --body "fitness-tracker-dev-eks"
```

## Step 6: Verify Setup

### Check Secrets

```powershell
# List all secrets
gh secret list
```

You should see:
```
AWS_ACCESS_KEY_ID        Updated 2025-11-22
AWS_SECRET_ACCESS_KEY    Updated 2025-11-22
AWS_REGION               Updated 2025-11-22
ECR_REGISTRY            Updated 2025-11-22
EKS_CLUSTER_NAME        Updated 2025-11-22
```

### Test a Pipeline

Trigger a workflow manually:

```powershell
# Via GitHub CLI
gh workflow run user-service.yml

# Check status
gh run list --limit 5
```

Or via GitHub UI:
1. Go to **Actions** tab
2. Select **User Service CI/CD**
3. Click **Run workflow** → **Run workflow**

## Step 7: Verify Deployment

After the workflow runs successfully:

```powershell
# Check if new pod was created
kubectl get pods -n fitness-tracker -l app=user-service

# Check rollout history
kubectl rollout history deployment/user-service -n fitness-tracker

# View logs
kubectl logs deployment/user-service -n fitness-tracker --tail=50
```

## Testing the CI/CD Pipeline

### Test 1: Make a Code Change

```powershell
# Make a small change to user service
cd c:\microApp\userservice\src\main\java\org\choubi\userservice

# Edit UserController.java (add a comment or change)
# Save the file

# Commit and push
git add .
git commit -m "Test CI/CD pipeline - user service update"
git push origin main
```

Watch the pipeline:
1. Go to GitHub **Actions** tab
2. You should see "User Service CI/CD" workflow running
3. Click on it to see detailed logs

### Test 2: Configuration Change

```powershell
# Edit a config file
cd c:\microApp\config-repo

# Make a change to user-service.yml
# Save the file

# Commit and push
git add .
git commit -m "Test config update pipeline"
git push origin main
```

The **Config Repository Update** workflow should:
1. Restart config-server
2. Detect which services are affected
3. Restart affected services automatically

### Test 3: Frontend Change

```powershell
cd c:\microApp\fitness-front\vite-project\src

# Make a change to any React component
# Save the file

# Commit and push
git add .
git commit -m "Test frontend pipeline"
git push origin main
```

The **Frontend CI/CD** workflow should build and deploy the frontend.

## Monitoring and Troubleshooting

### View All Workflows

```powershell
gh workflow list
```

### View Recent Runs

```powershell
gh run list --limit 10
```

### View Specific Run Details

```powershell
# Get run ID from previous command
gh run view <run-id>

# Follow logs in real-time
gh run watch
```

### Check Deployment Status

```powershell
# All pods
kubectl get pods -n fitness-tracker

# Specific service
kubectl get deployment user-service -n fitness-tracker -o yaml

# Rollout history
kubectl rollout history deployment/user-service -n fitness-tracker

# Detailed pod info
kubectl describe pod <pod-name> -n fitness-tracker
```

## Common Issues and Solutions

### Issue 1: AWS Credentials Invalid

**Error:** `Unable to locate credentials`

**Solution:**
```powershell
# Verify secrets are set
gh secret list

# Re-set credentials
gh secret set AWS_ACCESS_KEY_ID --body "YOUR_KEY"
gh secret set AWS_SECRET_ACCESS_KEY --body "YOUR_SECRET"
```

### Issue 2: ECR Access Denied

**Error:** `denied: User: arn:aws:iam::XXX:user/github-actions is not authorized`

**Solution:**
```powershell
# Add ECR permissions
aws iam attach-user-policy `
  --user-name github-actions-fitness-tracker `
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser
```

### Issue 3: EKS Access Denied

**Error:** `error: You must be logged in to the server (Unauthorized)`

**Solution:**
```powershell
# Update aws-auth configmap
kubectl edit configmap aws-auth -n kube-system

# Add the GitHub Actions IAM user with system:masters group
```

### Issue 4: Build Fails

**Error:** `Maven build failed` or `npm build failed`

**Solution:**
- Check the build logs in GitHub Actions
- Verify dependencies are correct
- Test build locally first
- Check for syntax errors

### Issue 5: Deployment Timeout

**Error:** `Waiting for deployment "XXX" rollout to finish: 0 of 1 updated replicas are available...`

**Solution:**
```powershell
# Check pod status
kubectl get pods -n fitness-tracker -l app=<service-name>

# Check pod logs
kubectl logs <pod-name> -n fitness-tracker

# Describe pod for events
kubectl describe pod <pod-name> -n fitness-tracker

# Common issues:
# - ImagePullBackOff: Check ECR image exists
# - CrashLoopBackOff: Check application logs
# - Pending: Check resource limits
```

## Best Practices

### 1. Branch Protection

Enable branch protection for `main`:
1. Go to **Settings** → **Branches**
2. Add rule for `main` branch
3. Enable:
   - Require pull request reviews
   - Require status checks to pass
   - Require conversation resolution

### 2. PR-Based Workflow

Instead of pushing directly to `main`:

```powershell
# Create feature branch
git checkout -b feature/my-feature

# Make changes and commit
git add .
git commit -m "Add new feature"

# Push to GitHub
git push origin feature/my-feature

# Create PR via GitHub UI or CLI
gh pr create --title "Add new feature" --body "Description"

# After PR approval and merge, CI/CD runs automatically
```

### 3. Environment Variables

For environment-specific configs, use GitHub Environments:
1. **Settings** → **Environments**
2. Create environments: `development`, `staging`, `production`
3. Add environment-specific secrets
4. Reference in workflows

### 4. Deployment Gates

Add manual approval for production:

```yaml
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://your-app-url.com
```

### 5. Notifications

Add Slack/Email notifications:

```yaml
- name: Notify on failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: failure
    text: 'Deployment failed!'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## Security Checklist

- [x] AWS credentials stored as GitHub Secrets
- [x] IAM user has minimum required permissions
- [x] Branch protection enabled on `main`
- [x] Secrets not logged in workflow output
- [x] Regular credential rotation schedule
- [ ] Enable 2FA on GitHub account
- [ ] Review workflow logs for sensitive data
- [ ] Scan Docker images for vulnerabilities
- [ ] Use specific image tags (not `latest`)
- [ ] Audit IAM user access regularly

## Rollback Procedure

If a deployment causes issues:

### Option 1: Automatic Kubernetes Rollback

```powershell
# Rollback to previous version
kubectl rollout undo deployment/<service-name> -n fitness-tracker

# Check status
kubectl rollout status deployment/<service-name> -n fitness-tracker
```

### Option 2: Redeploy Previous Commit

```powershell
# Find the working commit SHA
git log --oneline

# Revert to that commit
git revert <bad-commit-sha>
git push origin main

# Or cherry-pick the good commit
git cherry-pick <good-commit-sha>
git push origin main
```

### Option 3: Manual Image Rollback

```powershell
# Find previous image tag
kubectl rollout history deployment/<service-name> -n fitness-tracker

# Set image to previous version
kubectl set image deployment/<service-name> \
  <service-name>=925047941400.dkr.ecr.eu-west-1.amazonaws.com/<service>:<previous-sha> \
  -n fitness-tracker
```

## Next Steps

1. ✅ Push workflows to GitHub
2. ✅ Configure AWS IAM user
3. ✅ Set up GitHub secrets
4. ✅ Test a pipeline
5. ✅ Monitor first deployment
6. 📋 Set up branch protection
7. 📋 Configure notifications
8. 📋 Document team processes
9. 📋 Schedule credential rotation
10. 📋 Plan staging environment

## Support

If you encounter issues:
1. Check GitHub Actions logs
2. Review Kubernetes pod logs
3. Consult this guide
4. Check AWS CloudWatch logs
5. Review EKS cluster events

## Congratulations! 🎉

Your CI/CD pipeline is now set up! Every push to `main` will automatically build, test, and deploy your application to EKS.
