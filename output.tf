output "kubeconfig" {
  value = yamlencode(jsondecode(data.jq_query.kubeconfig.result) )
}

output "subaccount_id" {
  value = local.subaccount_id
}

output "service_instance_id" {
  value = btp_subaccount_environment_instance.kyma.id
}

output "cluster_id" {
  value = data.local_file.cluster_id.content
}

output "domain" {
  value = data.local_file.domain.content
}
