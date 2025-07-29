#!/bin/bash
# Fetch cluster ID and domain from Kyma cluster
# Prerequisite: kubectl must be installed and KUBECONFIG must be set

set -e -o pipefail

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
  echo "Error: kubectl is not installed. Please install kubectl and try again." >&2
  exit 1
fi

# Check if KUBECONFIG is set
if [ -z "$KUBECONFIG" ]; then
  echo "Error: KUBECONFIG is not set. Please set the KUBECONFIG environment variable and try again." >&2
  exit 1
fi

# Wait for Kyma CRD
while ! kubectl get crd kymas.operator.kyma-project.io --kubeconfig "$KUBECONFIG" &> /dev/null; do
  echo "Waiting for Kyma CRD..."
  sleep 1
done
kubectl wait --for condition=established crd/kymas.operator.kyma-project.io --kubeconfig "$KUBECONFIG"

# Wait for default Kyma CR
while ! kubectl get kyma default -n kyma-system --kubeconfig "$KUBECONFIG" &> /dev/null; do
  echo "Waiting for default Kyma CR..."
  sleep 1
done
kubectl wait --for='jsonpath={.status.state}=Ready' kymas.operator.kyma-project.io/default -n kyma-system --kubeconfig "$KUBECONFIG" --timeout=480s

# Wait for sap-btp-manager secret
while ! kubectl get secret sap-btp-manager -n kyma-system --kubeconfig "$KUBECONFIG" &> /dev/null; do
  echo "Waiting for sap-btp-manager secret..."
  sleep 1
done
kubectl get secret sap-btp-manager -n kyma-system -ojsonpath={.data.cluster_id} --kubeconfig "$KUBECONFIG" > cluster_id.txt

# Wait for shoot-info config map
while ! kubectl get cm shoot-info -n kube-system --kubeconfig "$KUBECONFIG" &> /dev/null; do
  echo "Waiting for shoot-info config map..."
  sleep 1
done
kubectl get cm shoot-info -n kube-system -ojsonpath={.data.domain} --kubeconfig "$KUBECONFIG" > domain.txt

echo "Cluster ID and domain have been successfully fetched and saved to cluster_id.txt and domain.txt."
