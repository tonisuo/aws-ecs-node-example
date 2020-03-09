provider "aws" {
  version = "~> 2.52"
  shared_credentials_file = "/home/toni/.aws/credentials"
  region = "eu-central-1"
  profile = "default"
}

module "vpc" {
  source = "./modules/vpc"
}

module "ecs" {
  source = "./modules/ecs"
}

module "alb" {
  source = "./modules/alb"
}



