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
