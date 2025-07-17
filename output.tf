output "subaccount_id" {
  description = "The ID of the subaccount where the Kyma environment is created."
  value       = local.subaccount_id
}

output "environment_instance_id" {
  description = "The ID of the Kyma environment instance."
  value       = btp_subaccount_environment_instance.kyma.id
}

output "kubeconfig" {
  description = "Kubeconfig for the Kyma environment."
  sensitive   = true
  value       = yamldecode(jsondecode(terracurl_request.cis_kyma_env_binding.response).credentials.kubeconfig)
}

output "apiserver_url" {
  description = "The API server URL of the Kyma cluster."
  value       = yamldecode(jsondecode(terracurl_request.cis_kyma_env_binding.response).credentials.kubeconfig).clusters.0.cluster.server
}
