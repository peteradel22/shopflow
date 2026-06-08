variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
variable "public_key" {
  description = "SSH public key for EC2 key pair"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag injected by CI pipeline"
  type        = string
}

variable "ecr_registry" {
  description = "ECR registry URL injected by CI pipeline"
  type        = string
}
