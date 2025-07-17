output "environment_instance_id" {
  description = "ID of the Kyma environment instance"
  value       = module.kyma.service_instance_id
}

output "cluster_id" {
  description = "ID of the Kyma cluster"
  value       = module.kyma.cluster_id
}

output "domain" {
  description = "Domain of the Kyma cluster"
  value       = module.kyma.domain
}
