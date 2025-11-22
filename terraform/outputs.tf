output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "eks_configure_kubectl" {
  description = "Configure kubectl command"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "ecr_repositories" {
  description = "ECR repository URLs"
  value       = module.ecr.repository_urls
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.endpoint
  sensitive   = true
}

output "rds_password" {
  description = "RDS master password"
  value       = module.rds.master_password
  sensitive   = true
}

# DocumentDB outputs - DISABLED (self-hosting MongoDB on EKS)
# output "documentdb_endpoint" {
#   description = "DocumentDB endpoint"
#   value       = module.documentdb.endpoint
#   sensitive   = true
# }

# output "documentdb_password" {
#   description = "DocumentDB master password"
#   value       = module.documentdb.master_password
#   sensitive   = true
# }

output "mq_amqp_endpoint" {
  description = "Amazon MQ AMQP endpoint"
  value       = module.mq.amqp_endpoint
  sensitive   = true
}

output "mq_console_url" {
  description = "Amazon MQ console URL"
  value       = module.mq.console_url
}

output "mq_username" {
  description = "Amazon MQ username"
  value       = module.mq.admin_username
  sensitive   = true
}

output "mq_password" {
  description = "Amazon MQ password"
  value       = module.mq.admin_password
  sensitive   = true
}

output "next_steps" {
  description = "Next steps after infrastructure is created"
  value = <<-EOT
    
    ✅ Infrastructure Created Successfully!
    
    Next Steps:
    1. Configure kubectl:
       ${module.eks.configure_kubectl_command}
    
    2. Verify cluster access:
       kubectl get nodes
    
    3. Push Docker images to ECR:
       aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
    
    4. Tag and push images (example):
       docker tag microapp-eureka-server:latest ${module.ecr.repository_urls["fitness-tracker-dev-eureka-server"]}:latest
       docker push ${module.ecr.repository_urls["fitness-tracker-dev-eureka-server"]}:latest
    
    5. Apply Kubernetes manifests (next phase):
       kubectl apply -f ../k8s/
    
    Database Credentials (save these securely):
    - RDS Endpoint: ${module.rds.endpoint}
    - RDS Password: Use 'terraform output -raw rds_password' to retrieve
    - MongoDB: Self-hosted on EKS (see k8s manifests in Phase 3)
    - MQ Console: ${module.mq.console_url}
    - MQ Credentials: Use 'terraform output -raw mq_username' and 'terraform output -raw mq_password'
    
  EOT
}
