# Fetch cluster ID and domain from Kyma cluster
# Prerequisite: kubectl.exe must be installed and KUBECONFIG must be set

# Check if kubectl.exe is installed
if (-not (Get-Command kubectl.exe -ErrorAction SilentlyContinue)) {
    Write-Error "Error: kubectl.exe is not installed. Please install kubectl and try again."
    exit 1
}

# Check if KUBECONFIG is set
if (-not $env:KUBECONFIG) {
    Write-Error "Error: KUBECONFIG is not set. Please set the KUBECONFIG environment variable and try again."
    exit 1
}

# Wait for Kyma CRD
while (-not (kubectl.exe get crd kymas.operator.kyma-project.io --kubeconfig $env:KUBECONFIG -ErrorAction SilentlyContinue)) {
    Write-Host "Waiting for Kyma CRD..."
    Start-Sleep -Seconds 1
}
kubectl.exe wait --for condition=established crd/kymas.operator.kyma-project.io --kubeconfig $env:KUBECONFIG

# Wait for default Kyma CR
while (-not (kubectl.exe get kyma default -n kyma-system --kubeconfig $env:KUBECONFIG -ErrorAction SilentlyContinue)) {
    Write-Host "Waiting for default Kyma CR..."
    Start-Sleep -Seconds 1
}
kubectl.exe wait --for='jsonpath={.status.state}=Ready' kymas.operator.kyma-project.io/default -n kyma-system --kubeconfig $env:KUBECONFIG --timeout=480s

# Wait for sap-btp-manager secret
while (-not (kubectl.exe get secret sap-btp-manager -n kyma-system --kubeconfig $env:KUBECONFIG -ErrorAction SilentlyContinue)) {
    Write-Host "Waiting for sap-btp-manager secret..."
    Start-Sleep -Seconds 1
}
kubectl.exe get secret sap-btp-manager -n kyma-system -ojsonpath={.data.cluster_id} --kubeconfig $env:KUBECONFIG | Out-File -Encoding ASCII cluster_id.txt

# Wait for shoot-info config map
while (-not (kubectl.exe get cm shoot-info -n kube-system --kubeconfig $env:KUBECONFIG -ErrorAction SilentlyContinue)) {
    Write-Host "Waiting for shoot-info config map..."
    Start-Sleep -Seconds 1
}
kubectl.exe get cm shoot-info -n kube-system -ojsonpath={.data.domain} --kubeconfig $env:KUBECONFIG | Out-File -Encoding ASCII domain.txt

Write-Host "Cluster ID and domain have been successfully fetched and saved to cluster_id.txt and domain.txt."
