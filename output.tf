output "kubeconfig" {
  value = yamldecode(jsondecode(data.http.kymaruntime_bindings.response_body).credentials.kubeconfig)
}

output "subaccount_id" {
  value = local.subaccount_id
}

output "service_instance_id" {
  value = btp_subaccount_environment_instance.kyma.id
}

output "cluster_id" {
  value = base64decode(data.local_file.cluster_id.content)
}

output "domain" {
  value = data.local_file.domain.content
}

output "apiserver_url" {
  value = yamldecode(yamldecode(jsondecode(data.http.kymaruntime_bindings.response_body).credentials.kubeconfig).clusters.0.cluster.server)
}