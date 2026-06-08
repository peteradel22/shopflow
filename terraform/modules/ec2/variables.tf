variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

variable "public_key" {
  description = "SSH public key for EC2 key pair"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
}

variable "ecr_registry" {
  description = "ECR registry URL"
  type        = string
}
