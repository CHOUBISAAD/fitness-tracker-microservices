# GitHub Actions CI/CD Pipelines

This directory contains GitHub Actions workflows for automated CI/CD of the Fitness Tracker application.

## Workflows Overview

### Service Pipelines

Each microservice has its own dedicated pipeline that triggers on code changes:

1. **user-service.yml** - User Service CI/CD
2. **activity-service.yml** - Activity Service CI/CD
3. **ai-service.yml** - AI Service CI/CD
4. **api-gateway.yml** - API Gateway CI/CD
5. **config-server.yml** - Config Server CI/CD
6. **eureka-server.yml** - Eureka Server CI/CD
7. **frontend.yml** - Frontend (React/Vite) CI/CD

### Configuration Pipeline

**config-update.yml** - Handles configuration changes in `config-repo/`
- Automatically restarts Config Server
- Detects which services are affected by config changes
- Restarts only the affected services
- Provides deployment summary

## Pipeline Flow

Each service pipeline follows this pattern:

```
1. Trigger (on push to main or manual dispatch)
   ↓
2. Checkout code
   ↓
3. Setup build environment (Java 17 or Node.js 20)
   ↓
4. Build application (Maven or npm)
   ↓
5. Configure AWS credentials
   ↓
6. Login to Amazon ECR
   ↓
7. Build Docker image
   ↓
8. Push to ECR (with commit SHA tag + latest tag)
   ↓
9. Update kubeconfig for EKS
   ↓
10. Deploy to Kubernetes (rolling update)
   ↓
11. Wait for rollout to complete
   ↓
12. Verify deployment
```

## Trigger Conditions

### Automatic Triggers
Pipelines trigger automatically when:
- Code is pushed to `main` branch
- Changes are made in the specific service directory
- Changes are made to the workflow file itself

### Manual Triggers
All workflows can be triggered manually via:
- GitHub UI: Actions tab → Select workflow → Run workflow
- GitHub CLI: `gh workflow run <workflow-name>`

## Required GitHub Secrets

Configure these secrets in your repository settings (Settings → Secrets and variables → Actions):

### AWS Credentials
- `AWS_ACCESS_KEY_ID` - AWS access key for ECR and EKS
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `AWS_REGION` - AWS region (currently: eu-west-1)

### Optional Secrets
- `GEMINI_API_KEY` - Google Gemini API key (if not using env var in k8s)

## Setting Up Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with its value

### Getting AWS Credentials

Option 1: Create IAM User (Recommended)
```bash
# Create IAM user with required permissions
aws iam create-user --user-name github-actions-fitness-tracker

# Attach policies
aws iam attach-user-policy --user-name github-actions-fitness-tracker \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser

aws iam attach-user-policy --user-name github-actions-fitness-tracker \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

# Create access key
aws iam create-access-key --user-name github-actions-fitness-tracker
```

Option 2: Use existing AWS credentials with appropriate permissions

## Deployment Strategy

### Rolling Updates
- Zero-downtime deployments
- New pods created before old ones are terminated
- Automatic rollback on failure
- 5-minute timeout for rollout completion

### Image Tagging Strategy
Each deployment creates two tags:
- `<commit-sha>` - Specific version for rollback capability
- `latest` - Always points to the most recent build

### Rollback
To rollback to a previous version:
```bash
# Find the previous image tag (commit SHA)
kubectl rollout history deployment/<service-name> -n fitness-tracker

# Rollback to previous version
kubectl rollout undo deployment/<service-name> -n fitness-tracker

# Or rollback to specific revision
kubectl rollout undo deployment/<service-name> -n fitness-tracker --to-revision=<number>
```

## Monitoring Deployments

### View Workflow Runs
1. Go to **Actions** tab in GitHub
2. Select the workflow you want to monitor
3. Click on a specific run to see detailed logs

### Check Deployment Status
```bash
# Get all pods status
kubectl get pods -n fitness-tracker

# Check specific deployment
kubectl get deployment <service-name> -n fitness-tracker

# View rollout status
kubectl rollout status deployment/<service-name> -n fitness-tracker

# View deployment history
kubectl rollout history deployment/<service-name> -n fitness-tracker
```

## Troubleshooting

### Build Failures

**Maven build fails:**
- Check Java version (must be 17)
- Verify dependencies in pom.xml
- Check build logs in GitHub Actions

**npm build fails:**
- Check Node.js version (must be 20)
- Verify package-lock.json is committed
- Check for environment variable issues

### Docker Build Failures

**Common issues:**
- Dockerfile not found → Check working directory
- Build context too large → Add .dockerignore
- Base image pull fails → Check internet connectivity

### Deployment Failures

**ECR push fails:**
- Verify AWS credentials are correct
- Check ECR repository exists
- Verify IAM permissions

**EKS deployment fails:**
- Check kubeconfig is updated correctly
- Verify namespace exists
- Check pod logs: `kubectl logs <pod-name> -n fitness-tracker`
- Verify image pull permissions

**Rollout timeout:**
- Check pod status: `kubectl describe pod <pod-name> -n fitness-tracker`
- Look for ImagePullBackOff, CrashLoopBackOff
- Check resource limits (CPU/Memory)
- Verify health checks

### Config Update Issues

**Services not restarting:**
- Check if config files were actually changed
- Verify file paths match exactly
- Check workflow logs for errors

**Service fails after config update:**
- Verify configuration syntax (YAML)
- Check config-server logs
- Manually restart: `kubectl rollout restart deployment/<service> -n fitness-tracker`

## Best Practices

### Code Changes
1. Create feature branch
2. Make and test changes locally
3. Push to feature branch (no pipeline trigger)
4. Create Pull Request
5. Review and merge to main (triggers pipeline)

### Testing Deployments
1. Monitor workflow in Actions tab
2. Wait for completion (usually 3-5 minutes)
3. Verify pods are running: `kubectl get pods -n fitness-tracker`
4. Test application endpoints
5. Check logs if issues: `kubectl logs deployment/<service> -n fitness-tracker`

### Configuration Changes
1. Update files in `config-repo/`
2. Test locally if possible
3. Push to main
4. Monitor config-update workflow
5. Verify services restarted successfully
6. Test affected functionality

## Manual Deployment

If you need to deploy manually without CI/CD:

```bash
# Build and push image
cd <service-directory>
mvn clean package -DskipTests
docker build -t 925047941400.dkr.ecr.eu-west-1.amazonaws.com/<service>:manual .
docker push 925047941400.dkr.ecr.eu-west-1.amazonaws.com/<service>:manual

# Update deployment
kubectl set image deployment/<service> <service>=925047941400.dkr.ecr.eu-west-1.amazonaws.com/<service>:manual -n fitness-tracker
kubectl rollout status deployment/<service> -n fitness-tracker
```

## Workflow Customization

### Adding Tests
Add before the "Build with Maven" step:

```yaml
- name: Run tests
  working-directory: ./<service-directory>
  run: mvn test
```

### Adding Security Scanning
Add after the "Build Docker image" step:

```yaml
- name: Run Trivy security scan
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ${{ env.ECR_REGISTRY }}/${{ env.ECR_REPOSITORY }}:${{ github.sha }}
    format: 'sarif'
    output: 'trivy-results.sarif'
```

### Adding Notifications
Add at the end of the workflow:

```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Deployment of ${{ env.DEPLOYMENT_NAME }} ${{ job.status }}'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## Performance Optimization

### Build Cache
- Maven dependencies cached via `actions/setup-java@v4`
- npm packages cached via `actions/setup-node@v4`
- Docker layer caching (implicit in GitHub Actions)

### Parallel Builds
Workflows run in parallel when multiple services change
- Each service has independent pipeline
- No dependencies between service workflows

### Resource Limits
- GitHub Actions: 6 hours max per workflow
- 20 concurrent jobs for free tier
- Consider self-hosted runners for high volume

## Security Considerations

### Secrets Management
- Never commit secrets to repository
- Use GitHub Secrets for sensitive data
- Rotate AWS credentials regularly
- Use IAM roles with least privilege

### Image Security
- Base images from trusted sources only
- Regular security scanning
- Keep dependencies updated
- Use specific version tags, not `latest` in production

### Access Control
- Limit who can approve workflow runs
- Protect main branch with required reviews
- Use branch protection rules
- Enable required status checks

## Cost Optimization

### GitHub Actions Minutes
- Free tier: 2,000 minutes/month for private repos
- Public repos: unlimited
- Each workflow run: ~3-5 minutes
- Estimate: ~100 deployments/month = 500 minutes

### AWS Costs
- ECR storage: ~$0.10/GB/month
- Data transfer: Free within region
- EKS API calls: Minimal cost

### Tips to Reduce Costs
- Use path filters to avoid unnecessary builds
- Combine related changes in single commit
- Use manual triggers for non-critical updates
- Clean up old ECR images regularly

## Support and Maintenance

### Regular Tasks
- Review workflow runs weekly
- Update GitHub Actions versions quarterly
- Rotate AWS credentials every 90 days
- Clean up old ECR images monthly

### Health Checks
```bash
# Check all pipelines status
gh workflow list

# View recent runs
gh run list --limit 10

# Check specific workflow
gh run view <run-id>
```

### Getting Help
- Check workflow logs in GitHub Actions tab
- Review Kubernetes pod logs
- Consult AWS CloudWatch for EKS logs
- Check this README for troubleshooting tips

## Future Enhancements

Potential improvements:
- [ ] Add automated testing (unit, integration)
- [ ] Implement blue-green deployments
- [ ] Add canary deployments
- [ ] Integrate security scanning (Trivy, Snyk)
- [ ] Add performance testing
- [ ] Implement automatic rollback on errors
- [ ] Add deployment notifications (Slack, email)
- [ ] Create staging environment pipeline
- [ ] Add code quality checks (SonarQube)
- [ ] Implement artifact versioning
