output "endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "address" {
  description = "RDS address (hostname)"
  value       = aws_db_instance.postgres.address
}

output "port" {
  description = "RDS port"
  value       = aws_db_instance.postgres.port
}

output "database_name" {
  description = "Database name"
  value       = aws_db_instance.postgres.db_name
}

output "master_username" {
  description = "Master username"
  value       = aws_db_instance.postgres.username
  sensitive   = true
}

output "master_password" {
  description = "Master password"
  value       = random_password.master.result
  sensitive   = true
}

output "connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${aws_db_instance.postgres.username}:${random_password.master.result}@${aws_db_instance.postgres.endpoint}/${aws_db_instance.postgres.db_name}"
  sensitive   = true
}
