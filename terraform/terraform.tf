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
variable "desired_task_count" {}
variable "access_key_id" {}
variable "secret_access_key" {}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr    = var.vpc_cidr
  environment = var.environment
  managed_by  = var.managed_by
  app_name    = var.app_name
  az_count    = var.az_count
}

module "ecs" {
  source = "./modules/ecs-with-external-api"

  region               = var.region
  repository_name      = var.repository_name
  vpc_cidr             = var.vpc_cidr
  vpc_id               = module.vpc.vpc_id
  environment          = var.environment
  managed_by           = var.managed_by
  app_name             = var.app_name
  az_count             = var.az_count

  private_subnets      = module.vpc.private_subnet_ids
  public_subnets       = module.vpc.public_subnet_ids

  desired_task_count   = var.desired_task_count

  access_key_id        = var.access_key_id
  secret_access_key    = var.secret_access_key
}

module "ddb" {
  source = "./modules/ddb"

  table_name  = "Town"
  environment = var.environment
  managed_by  = var.managed_by
}