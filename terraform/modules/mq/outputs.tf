output "id" {
  description = "Amazon MQ broker ID"
  value       = aws_mq_broker.rabbitmq.id
}

output "arn" {
  description = "Amazon MQ broker ARN"
  value       = aws_mq_broker.rabbitmq.arn
}

output "amqp_endpoint" {
  description = "AMQPS endpoint for RabbitMQ"
  value       = aws_mq_broker.rabbitmq.instances[0].endpoints[0]
}

output "console_url" {
  description = "Management console URL"
  value       = aws_mq_broker.rabbitmq.instances[0].console_url
}

output "admin_username" {
  description = "Admin username"
  value       = var.admin_username
  sensitive   = true
}

output "admin_password" {
  description = "Admin password"
  value       = random_password.admin.result
  sensitive   = true
}
