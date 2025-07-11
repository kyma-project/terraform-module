output "subaccount_id" {
  description = "The ID of the subaccount where the Kyma environment is created."
  value       = local.subaccount_id
}

output "environment_instance_id" {
  description = "The ID of the Kyma environment instance."
  value       = btp_subaccount_environment_instance.kyma.id
}

output "kubeconfig" {
  description = "value of the kubeconfig for the Kyma environment."
  sensitive   = true
  value       = yamldecode(jsondecode(data.http.kymaruntime_bindings.response_body).credentials.kubeconfig)
}

output "cluster_id" {
  description = "The ID of the Kyma cluster."
  value       = base64decode(data.local_file.cluster_id.content)
}

output "domain" {
  description = "The domain of the Kyma cluster."
  value       = data.local_file.domain.content
}

output "apiserver_url" {
  description = "The API server URL of the Kyma cluster."
  value       = yamldecode(jsondecode(data.http.kymaruntime_bindings.response_body).credentials.kubeconfig).clusters.0.cluster.server
}
