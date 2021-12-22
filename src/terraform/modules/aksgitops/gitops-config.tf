data "azurerm_client_config" "current" {}

resource "null_resource" "install_extension" {
  provisioner "local-exec" {
    command = <<EOT
      az extension add --name k8s-extension
      az extension add --name k8s-configuration
      az extension add --name aks-preview
      az extension list -o table
    EOT

  }
}


resource "null_resource" "flux-system-exception" {

  count = var.enable_gitops != false ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      az aks pod-identity exception add -g ${data.azurerm_resource_group.aks.name} \
        --cluster-name ${azurerm_kubernetes_cluster.aks.name} \
        --namespace flux-system \
        --pod-labels app.kubernetes.io\/name=flux-extension
    EOT
  }
  depends_on = [
    null_resource.enable-pod-identity
  ]
}


resource "null_resource" "install_gitops_configuration" {

  count = var.enable_gitops != false ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      az config set extension.use_dynamic_install=yes_without_prompt
      az login --service-principal -u $VAR_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $VAR_TENANT_ID
      az k8s-configuration flux create -g ${data.azurerm_resource_group.aks.name} \
        --cluster-name ${azurerm_kubernetes_cluster.aks.name} \
        --name infra-apps-flux-config --cluster-type managedClusters \
        --sync-interval 30s --ns cluster-config -s cluster \
        -u ${var.git_repo} --branch ${var.git_branch} \
        --ssh-private-key $SSH_PRIV_KEY_BASE64 \
        --kustomization name=infra path=./src/gitops/infra prune=true sync_interval=30s \
        --kustomization name=apps path=./src/gitops/apps/ prune=true sync_interval=30s dependsOn=infra
    EOT
    environment = {
      SSH_PRIV_KEY_BASE64 = var.ssh_priv_key_base64
      VAR_CLIENT_ID = var.sp_clientid
      VAR_TENANT_ID = var.sp_tenantid
    }
  }

  triggers = {
    id = azurerm_kubernetes_cluster.aks.id
  }

  depends_on = [
    null_resource.flux-system-exception
  ]
}
