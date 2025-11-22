output "endpoint" {
  description = "DocumentDB cluster endpoint"
  value       = aws_docdb_cluster.main.endpoint
}

output "reader_endpoint" {
  description = "DocumentDB cluster reader endpoint"
  value       = aws_docdb_cluster.main.reader_endpoint
}

output "port" {
  description = "DocumentDB port"
  value       = aws_docdb_cluster.main.port
}

output "master_username" {
  description = "Master username"
  value       = aws_docdb_cluster.main.master_username
  sensitive   = true
}

output "master_password" {
  description = "Master password"
  value       = random_password.master.result
  sensitive   = true
}

output "connection_string" {
  description = "MongoDB connection string"
  value       = "mongodb://${aws_docdb_cluster.main.master_username}:${random_password.master.result}@${aws_docdb_cluster.main.endpoint}:${aws_docdb_cluster.main.port}/?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
  sensitive   = true
}
