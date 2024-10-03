output "kubeconfig" {
  value = yamlencode(jsondecode(data.jq_query.kubeconfig.result) )
}

output "subaccount_id" {
  value = local.subaccount_id
}

output "service_instance_id" {
  value = btp_subaccount_environment_instance.kyma.id
}

output "service_id" {
  value = data.btp_subaccount_environment_instance.kyma-instance.service_id
}

output "platform_id" {
  value = data.btp_subaccount_environment_instance.kyma-instance.platform_id
}
