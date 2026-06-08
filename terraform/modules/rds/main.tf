resource "aws_db_subnet_group" "main" {
  name = "shopflow-db-subnet-group"

  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "shopflow-db-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "shopflow-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ec2_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "mysql" {
  identifier          = "shopflow-db"
  allocated_storage   = 20
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  username            = "admin"
  password            = "ShopFlow123!"
  skip_final_snapshot = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}