data "btp_subaccount" "reuse_subaccount" {
  count = var.BTP_USE_SUBACCOUNT_ID != null ? 1 : 0
  id    = var.BTP_USE_SUBACCOUNT_ID
}

locals {
  subaccount_name = var.BTP_USE_SUBACCOUNT_ID != null ? one(data.btp_subaccount.reuse_subaccount).name : one(btp_subaccount.subaccount).name
  subaccount_id   = var.BTP_USE_SUBACCOUNT_ID != null ? one(data.btp_subaccount.reuse_subaccount).id : one(btp_subaccount.subaccount).id
  default_kyma_modules = [
    {
      name    = "istio"
      channel = "fast"
    },
    {
      name    = "api-gateway"
      channel = "fast"
    },
    {
      name    = "btp-operator"
      channel = "fast"
    }
  ]
  merged_kyma_modules = distinct(concat(local.default_kyma_modules, var.BTP_KYMA_MODULES))
}

###
# Setup the subaccount including entitlements for Kyma
###
resource "btp_subaccount" "subaccount" {
  count     = var.BTP_USE_SUBACCOUNT_ID == null ? 1 : 0
  name      = var.BTP_NEW_SUBACCOUNT_NAME
  region    = var.BTP_NEW_SUBACCOUNT_REGION
  subdomain = var.BTP_NEW_SUBACCOUNT_NAME
}


resource "btp_subaccount_entitlement" "kyma" {
  subaccount_id = local.subaccount_id
  service_name  = "kymaruntime"
  plan_name     = var.BTP_KYMA_PLAN
  amount        = 1
}

resource "btp_subaccount_entitlement" "sm-operator-access" {
  subaccount_id = local.subaccount_id
  service_name  = "service-manager"
  plan_name     = "service-operator-access"
}

###
# Setup CIS
###
resource "btp_subaccount_entitlement" "cis" {
  subaccount_id = local.subaccount_id
  service_name  = "cis"
  plan_name     = "local"
}

data "btp_subaccount_service_plan" "cis" {
  depends_on = [btp_subaccount_entitlement.cis]

  subaccount_id = local.subaccount_id
  offering_name = "cis"
  name          = "local"
}

resource "btp_subaccount_service_instance" "cis-local" {
  depends_on = [btp_subaccount_entitlement.cis]

  subaccount_id  = local.subaccount_id
  name           = "cis-local"
  serviceplan_id = data.btp_subaccount_service_plan.cis.id
  parameters = jsonencode({
    "grantType" : "clientCredentials"
  })
}

resource "btp_subaccount_service_binding" "cis-local-binding" {
  depends_on = [btp_subaccount_service_instance.cis-local]

  subaccount_id       = local.subaccount_id
  name                = "cis-local-binding"
  service_instance_id = btp_subaccount_service_instance.cis-local.id
}

locals {
  cisCredentials = jsondecode(btp_subaccount_service_binding.cis-local-binding.credentials)
  cisBasicAuth   = base64encode("${local.cisCredentials.uaa.clientid}:${local.cisCredentials.uaa.clientsecret}")
}

# Fetch token from CIS API using client-credential service binding
data "http" "cis-api-token" {
  depends_on = [btp_subaccount_service_binding.cis-local-binding]

  url    = "${local.cisCredentials.uaa.url}/oauth/token?grant_type=client_credentials"
  method = "POST"
  request_headers = {
    Authorization = "Basic ${local.cisBasicAuth}"
  }
}

###
# Setup the Kyma environment
###
resource "btp_subaccount_environment_instance" "kyma" {
  depends_on = [resource.btp_subaccount_entitlement.sm-operator-access]

  subaccount_id    = local.subaccount_id
  name             = "${local.subaccount_name}-kyma"
  environment_type = "kyma"
  service_name     = btp_subaccount_entitlement.kyma.service_name
  plan_name        = btp_subaccount_entitlement.kyma.plan_name
  parameters = jsonencode({
    modules        = { list = local.merged_kyma_modules }
    oidc           = var.BTP_KYMA_CUSTOM_OIDC
    name           = "${local.subaccount_name}-kyma"
    region         = var.BTP_KYMA_REGION
    administrators = var.BTP_KYMA_CUSTOM_ADMINISTRATORS
    autoScalerMin  = var.BTP_KYMA_AUTOSCALER_MIN
    autoScalerMax  = var.BTP_KYMA_AUTOSCALER_MAX
  })
  timeouts = {
    create = var.BTP_KYMA_SETUP_TIMEOUTS.create
    update = var.BTP_KYMA_SETUP_TIMEOUTS.update
    delete = var.BTP_KYMA_SETUP_TIMEOUTS.delete
  }
}

###
# Create Kyma environment binding via CIS provisioning API
###

# For DELETE we must make a READ request first to get the binding ID
data "http" "cis-kyma-env-binding-read" {
  depends_on = [data.http.cis-api-token, btp_subaccount_environment_instance.kyma]

  url    = "${local.cisCredentials.endpoints.provisioning_service_url}/provisioning/v1/environments/${btp_subaccount_environment_instance.kyma.id}/bindings"
  method = "GET"
  request_headers = {
    Authorization = "Bearer ${jsondecode(data.http.cis-api-token.response_body).access_token}"
    Accept        = "application/json"
    content-type  = "application/json"
  }
}

locals {
  existing_binding_id = length(data.http.cis-kyma-env-binding-read.response_body) > 0 ? jsondecode(data.http.cis-kyma-env-binding-read.response_body).bindings[0].bindingId : null
}

resource "terracurl_request" "cis-kyma-env-binding" {
  depends_on = [data.http.cis-api-token, btp_subaccount_environment_instance.kyma]

  name         = "cis-kyma-env-binding"
  url          = "${local.cisCredentials.endpoints.provisioning_service_url}/provisioning/v1/environments/${btp_subaccount_environment_instance.kyma.id}/bindings"
  method       = "PUT"
  request_body = <<EOF
{
  "parameters": {
    "expiration_seconds" : 7200,
  }
}

EOF

  headers = {
    Authorization = "Bearer ${jsondecode(data.http.cis-api-token.response_body).access_token}"
    Accept        = "application/json"
    content-type  = "application/json"
  }

  response_codes = [202]

  destroy_url    = "${local.cisCredentials.endpoints.provisioning_service_url}/provisioning/v1/environments/${btp_subaccount_environment_instance.kyma.id}/bindings/"
  destroy_method = "DELETE"

  destroy_headers = {
    Authorization = "Bearer ${jsondecode(data.http.cis-api-token.response_body).access_token}"
    Accept        = "application/json"
    content-type  = "application/json"
  }

  destroy_response_codes = [200]

}

###
# Store the kubeconfig and CA certificate in local files after CIS binding is available
###
resource "local_sensitive_file" "kubeconfig-yaml" {
  filename = "kubeconfig.yaml"
  content  = jsondecode(terracurl_request.cis-kyma-env-binding.response).credentials.kubeconfig
}

resource "local_sensitive_file" "ca-cert" {
  filename = "CA.crt"
  content  = base64decode(yamldecode(jsondecode(terracurl_request.cis-kyma-env-binding.response).credentials.kubeconfig).clusters.0.cluster.certificate-authority-data)
}

###
# Wait for Kyma to become ready and extract the cluster ID and domain and write it to the local file system
###
# TODO Rewrite the script to have the script in a seperate file and react on the ritht OS acrhictecture namely amd64 and arm64
resource "terraform_data" "wait-for-kyma-readiness" {
  depends_on = [resource.local_sensitive_file.kubeconfig-yaml]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOF
       (
      KUBECONFIG=kubeconfig.yaml
      set -e -o pipefail ;\
      ARCH=$(uname -m)
      if ! which kubectl; then
        echo "Installing kubectl..."
        if [ "$ARCH" = "x86_64" ]; then
          ARCH="amd64"
        elif [ "$ARCH" = "aarch64" ]; then
          ARCH="arm64"
        else
          echo "Unsupported architecture: $ARCH"
          exit 1
        fi
        curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$ARCH/kubectl
        curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$ARCH/kubectl.sha256" &> /dev/null
        echo "Validating kubectl ..."
        echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
        chmod +x kubectl
      fi
      while ! kubectl get crd kymas.operator.kyma-project.io --kubeconfig $KUBECONFIG; do echo "Waiting for Kyma CRD..."; sleep 1; done
      kubectl wait --for condition=established crd/kymas.operator.kyma-project.io --kubeconfig $KUBECONFIG
      while ! kubectl get kyma default -n kyma-system --kubeconfig $KUBECONFIG; do echo "Waiting for default kyma CR..."; sleep 1; done
      kubectl wait --for='jsonpath={.status.state}=Ready' kymas.operator.kyma-project.io/default -n kyma-system --kubeconfig $KUBECONFIG --timeout=480s
      while ! kubectl get secret sap-btp-manager -n kyma-system --kubeconfig $KUBECONFIG; do echo "Waiting for sap-btp-manager..."; sleep 1; done
      kubectl get secret sap-btp-manager -n kyma-system -ojsonpath={.data.cluster_id} --kubeconfig $KUBECONFIG > cluster_id.txt
      while ! kubectl get cm shoot-info -n kube-system --kubeconfig $KUBECONFIG; do echo "Waiting for shoot-info cm..."; sleep 1; done
      kubectl get cm shoot-info -n kube-system -ojsonpath={.data.domain} --kubeconfig $KUBECONFIG  > domain.txt
       )
     EOF
  }
}


###
# Read the  cluster ID and domain from the local file system - needed to transfer the information to the output
###
data "local_file" "cluster_id" {
  depends_on = [resource.terraform_data.wait-for-kyma-readiness]
  filename   = "cluster_id.txt"
}

data "local_file" "domain" {
  depends_on = [resource.terraform_data.wait-for-kyma-readiness]
  filename   = "domain.txt"
}
