module "vpc" {
  source = "./modules/vpc"
}

module "iam" {
  source = "./modules/iam"
}

module "ec2" {
  source                = "./modules/ec2"
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  instance_profile_name = module.iam.instance_profile_name
  public_key            = var.public_key
  image_tag             = var.image_tag
  ecr_registry          = var.ecr_registry
}

module "rds" {
  source             = "./modules/rds"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ec2_sg_id          = module.ec2.ec2_sg_id
}
output "alb_dns_name" {
  value = module.ec2.alb_dns_name
}
