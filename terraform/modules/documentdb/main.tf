resource "random_password" "master" {
  length  = 16
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_security_group" "docdb" {
  name        = "${var.project_name}-${var.environment}-docdb-sg"
  description = "Security group for DocumentDB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [var.node_security_group_id]
    description     = "Allow MongoDB from EKS nodes"
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
      Name = "${var.project_name}-${var.environment}-docdb-sg"
    }
  )
}

resource "aws_docdb_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-docdb-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-docdb-subnet-group"
    }
  )
}

resource "aws_docdb_cluster" "main" {
  cluster_identifier      = "${var.project_name}-${var.environment}-docdb"
  engine                  = "docdb"
  engine_version          = var.engine_version
  master_username         = var.master_username
  master_password         = random_password.master.result
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = "03:00-04:00"
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_docdb_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.docdb.id]
  storage_encrypted       = true

  enabled_cloudwatch_logs_exports = ["audit", "profiler"]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-docdb"
    }
  )
}

resource "aws_docdb_cluster_instance" "instances" {
  count              = var.instance_count
  identifier         = "${var.project_name}-${var.environment}-docdb-${count.index}"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = var.instance_class

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-docdb-${count.index}"
    }
  )
}
