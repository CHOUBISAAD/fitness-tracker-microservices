# Prerequisites Installation Guide

Before deploying to AWS, you need to install several tools. This guide provides step-by-step instructions.

## Required Tools

1. **Terraform** - Infrastructure as Code tool
2. **AWS CLI** - Amazon Web Services Command Line Interface  
3. **kubectl** - Kubernetes command-line tool

## Installation Steps

### 1. Install Terraform

**Option A: Download Manually** (Recommended - no admin rights needed)

1. Download Terraform for Windows:
   ```
   https://releases.hashicorp.com/terraform/1.13.5/terraform_1.13.5_windows_amd64.zip
   ```

2. Extract the ZIP file to a folder (e.g., `C:\terraform`)

3. Add to PATH (current session):
   ```powershell
   $env:Path += ";C:\terraform"
   ```

4. Verify installation:
   ```powershell
   terraform version
   ```

**Option B: Using Chocolatey** (Requires admin PowerShell)

```powershell
# Run PowerShell as Administrator
choco install terraform -y
```

### 2. Install AWS CLI

**Option A: MSI Installer** (Recommended)

1. Download AWS CLI v2 for Windows:
   ```
   https://awscli.amazonaws.com/AWSCLIV2.msi
   ```

2. Run the installer (double-click the downloaded file)

3. Restart PowerShell after installation

4. Verify installation:
   ```powershell
   aws --version
   ```

**Option B: Using Chocolatey** (Requires admin)

```powershell
choco install awscli -y
```

### 3. Install kubectl

**Option A: Direct Download**

1. Download kubectl for Windows:
   ```
   https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe
   ```

2. Move to a folder in your PATH (e.g., same folder as Terraform)

3. Verify installation:
   ```powershell
   kubectl version --client
   ```

**Option B: Using Chocolatey** (Requires admin)

```powershell
choco install kubernetes-cli -y
```

## Quick Install Script (Run as Administrator)

If you have admin rights, save this as `install-tools.ps1` and run:

```powershell
# Check if running as admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run as Administrator!"
    exit
}

# Install Chocolatey if not installed
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install tools
Write-Host "Installing Terraform..."
choco install terraform -y

Write-Host "Installing AWS CLI..."
choco install awscli -y

Write-Host "Installing kubectl..."
choco install kubernetes-cli -y

Write-Host "`nInstallation complete! Please restart PowerShell."
Write-Host "Then verify with:"
Write-Host "  terraform version"
Write-Host "  aws --version"
Write-Host "  kubectl version --client"
```

## Configure AWS Credentials

After installing AWS CLI, configure your credentials:

```powershell
aws configure
```

You'll be prompted for:
- **AWS Access Key ID**: (from your AWS account)
- **AWS Secret Access Key**: (from your AWS account)
- **Default region name**: `eu-west-1`
- **Default output format**: `json`

### Getting AWS Credentials

1. Log into AWS Console: https://console.aws.amazon.com
2. Click your username (top-right) → Security credentials
3. Scroll to "Access keys" section
4. Click "Create access key"
5. Select "CLI" use case
6. Copy the Access Key ID and Secret Access Key

## Verify Setup

After installation and configuration, run these commands:

```powershell
# Check Terraform
terraform version
# Expected: Terraform v1.13.5 (or later)

# Check AWS CLI
aws --version
# Expected: aws-cli/2.x.x Python/3.x.x Windows/...

# Check kubectl
kubectl version --client
# Expected: Client Version: v1.28.0

# Verify AWS credentials
aws sts get-caller-identity
# Expected: JSON with your AWS account ID, user ARN

# Check AWS region
aws configure get region
# Expected: eu-west-1
```

## Troubleshooting

### "terraform is not recognized"
- **Solution**: Add Terraform to PATH or use full path `C:\terraform\terraform.exe`
- **Temporary**: `$env:Path += ";C:\terraform"`
- **Permanent**: System Properties → Environment Variables → Edit PATH

### "aws is not recognized"
- **Solution**: Restart PowerShell after AWS CLI installation
- **Check**: Look for `C:\Program Files\Amazon\AWSCLIV2\aws.exe`

### "Access Denied" errors with Chocolatey
- **Solution**: Run PowerShell as Administrator
- **Alternative**: Use manual download options above

### AWS CLI configuration fails
- **Solution**: Ensure you have valid Access Key ID and Secret Key
- **Check**: AWS Console → IAM → Users → Your user → Security credentials

### "InvalidClientTokenId" error
- **Solution**: Your AWS credentials are invalid or expired
- **Fix**: Run `aws configure` again with correct credentials

## Alternative: Use AWS CloudShell

If you can't install tools locally, use AWS CloudShell:

1. Log into AWS Console
2. Click the CloudShell icon (terminal icon) in the top bar
3. Wait for shell to initialize (~30 seconds)
4. CloudShell has AWS CLI, kubectl, and other tools pre-installed
5. Upload Terraform files using "Actions" → "Upload file"

**Note**: Terraform is NOT pre-installed in CloudShell. You'll need to:
```bash
# In CloudShell (Linux)
wget https://releases.hashicorp.com/terraform/1.13.5/terraform_1.13.5_linux_amd64.zip
unzip terraform_1.13.5_linux_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/
terraform version
```

## Next Steps

Once all tools are installed and AWS is configured:

1. Navigate to terraform directory:
   ```powershell
   cd c:\microApp\terraform
   ```

2. Initialize Terraform:
   ```powershell
   terraform init
   ```

3. Validate configuration:
   ```powershell
   terraform validate
   ```

4. Review infrastructure plan:
   ```powershell
   terraform plan
   ```

5. Apply infrastructure (create resources):
   ```powershell
   terraform apply
   ```

**Estimated time**: 15-20 minutes to create all AWS resources

## Summary

| Tool | Purpose | Installation Time |
|------|---------|-------------------|
| Terraform | Infrastructure as Code | 2-5 minutes |
| AWS CLI | Interact with AWS services | 3-5 minutes |
| kubectl | Manage Kubernetes clusters | 1-2 minutes |
| **Total** | | **~10 minutes** |

After installation, configuration takes another 5 minutes (AWS credentials, testing).

**Total setup time: ~15 minutes before you can run `terraform apply`**
