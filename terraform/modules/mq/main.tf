resource "random_password" "admin" {
  length  = 16
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_security_group" "mq" {
  name        = "${var.project_name}-${var.environment}-mq-sg"
  description = "Security group for Amazon MQ RabbitMQ"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5671
    to_port         = 5671
    protocol        = "tcp"
    security_groups = [var.node_security_group_id]
    description     = "Allow AMQPS from EKS nodes"
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.node_security_group_id]
    description     = "Allow HTTPS management console from EKS nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-mq-sg"
    }
  )
}

resource "aws_mq_broker" "rabbitmq" {
  broker_name        = "${var.project_name}-${var.environment}-rabbitmq"
  engine_type        = "RabbitMQ"
  engine_version     = var.engine_version
  host_instance_type = var.instance_type
  deployment_mode    = var.deployment_mode
  auto_minor_version_upgrade = true

  subnet_ids         = var.deployment_mode == "SINGLE_INSTANCE" ? [var.private_subnet_ids[0]] : var.private_subnet_ids
  security_groups    = [aws_security_group.mq.id]
  publicly_accessible = false

  user {
    username = var.admin_username
    password = random_password.admin.result
  }

  logs {
    general = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-rabbitmq"
    }
  )
}
