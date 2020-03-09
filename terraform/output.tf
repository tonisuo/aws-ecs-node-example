output "load_balancer_address" {
  value = module.ecs.load_balancer_address
}

output "ecr_repo_url" {
  value = module.ecs.ecr_repo_url
}

output "ecs_service_name" {
  value = module.ecs.ecs_service_name
}

output "ecs_cluster_name" {
  value = module.ecs.ecs_cluster_name
}