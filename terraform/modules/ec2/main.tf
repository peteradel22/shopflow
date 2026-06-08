####################################
# ECR
####################################
resource "aws_ecr_repository" "shopflow" {
  name = "shopflow-app"
}

####################################
# SECURITY GROUPS
####################################
resource "aws_security_group" "alb_sg" {
  name   = "shopflow-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name   = "shopflow-ec2-sg"
  vpc_id = var.vpc_id

  # ALB forwards to port 3000 on EC2
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

####################################
# KEY PAIR
####################################
resource "aws_key_pair" "shopflow" {
  key_name   = "shopflow-key"
  public_key = var.public_key
}

####################################
# BASTION HOST
####################################
resource "aws_instance" "bastion" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_ids[0]
  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]
  key_name = aws_key_pair.shopflow.key_name
  tags = {
    Name = "shopflow-bastion"
  }
}

####################################
# ALB
####################################
resource "aws_lb" "alb" {
  name               = "shopflow-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
  tags = {
    Name = "shopflow-alb"
  }
}

####################################
# TARGET GROUP
####################################
resource "aws_lb_target_group" "tg" {
  name     = "shopflow-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    port                = "3000"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }
}

####################################
# LISTENER
####################################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

####################################
# LAUNCH TEMPLATE
####################################
resource "aws_launch_template" "lt" {
  name_prefix   = "shopflow-"
  image_id      = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.shopflow.key_name

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    security_groups = [aws_security_group.ec2_sg.id]
  }

  user_data = base64encode(file("${path.module}/userdata.sh"))
}

####################################
# ASG
####################################
resource "aws_autoscaling_group" "asg" {
  name             = "shopflow-asg"
  min_size         = 1
  max_size         = 3
  desired_capacity = 2

  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
}
