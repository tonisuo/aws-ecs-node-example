provider "aws" {
  version                 = "~> 2.52"
  shared_credentials_file = "/home/toni/.aws/credentials"
  region                  = "eu-central-1"
  profile                 = "default"
}

variable "repository_name" {}
variable "region" {}          
variable "managed_by" {}      
variable "app_name" {}        
variable "environment" {}     
variable "vpc_cidr" {}        
variable "az_count" {}        


module "vpc" {
  source = "./modules/vpc"

  vpc_cidr    = var.vpc_cidr
  environment = var.environment
  managed_by  = var.managed_by
  app_name    = var.app_name
  az_count    = var.az_count
}

module "ecs" {
  source = "./modules/ecs"

  region      = var.region
  repository_name = var.repository_name
  vpc_cidr    = var.vpc_cidr
  vpc_id      = module.vpc.vpc_id
  #alb_sg_id   = module.alb.alb_sg_id
  environment = var.environment
  managed_by  = var.managed_by
  app_name    = var.app_name
  az_count    = var.az_count

  private_subnets = module.vpc.private_subnet_ids
  #alb_target_group_id = module.alb.alb_target_group_id
  vpc_public_subnet_id = module.vpc.public_subnet_ids
}