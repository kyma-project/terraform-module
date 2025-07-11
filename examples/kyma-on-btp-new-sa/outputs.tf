output "subaccount_id" {
  description = "ID of the subaccount on SAP BTP"
  value       = module.kyma.subaccount_id
}

output "environment_instance_id" {
  description = "Id of the Kyma environment instance"
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

output "apiserver_url" {
  description = "API server URL of the Kyma cluster"
  value       = module.kyma.apiserver_url
}
