data "azurerm_client_config" "current" {}

# Because every job runs on a fresh agent, this is useless
# resource "null_resource" "install_extension" {
#   provisioner "local-exec" {
#     command = <<EOT
#       az extension add --name k8s-extension
#       az extension add --name k8s-configuration
#       az extension add --name aks-preview
#       az extension list -o table
#     EOT

#   }
# }


resource "null_resource" "flux-system-exception" {

  count = var.enable_gitops != false ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      set -ex
      if [ -n "$ARM_CLIENT_ID" ]; then
        # We are running on an Azure DevOps agent, need to log in
        az login --service-principal \
                 --username "$ARM_CLIENT_ID" \
                 --password "$ARM_CLIENT_SECRET" \
                 --tenant "$ARM_TENANT_ID" \
                 --output none
      fi

      az extension add --name aks-preview

      az aks pod-identity exception add -g ${var.resource_group_name} \
        --cluster-name ${azurerm_kubernetes_cluster.aks.name} \
        --namespace flux-system \
        --pod-labels app.kubernetes.io\/name=flux-extension --only-show-errors
    EOT
  }
  depends_on = [
    null_resource.enable-pod-identity
  ]
}


resource "null_resource" "install_gitops_configuration" {

  #This is to enforce execution at every run, to apply SSH key rotation
  triggers = {
    id         = azurerm_kubernetes_cluster.aks.id
    always_run = "${timestamp()}"
  }


  count = var.enable_gitops != false ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      az config set extension.use_dynamic_install=yes_without_prompt

      az extension add --name k8s-extension
      az extension add --name k8s-configuration
      az extension add --name aks-preview

      set -ex
      if [ -n "$ARM_CLIENT_ID" ]; then
        # We are running on an Azure DevOps agent, need to log in
        az login --service-principal \
            --username "$ARM_CLIENT_ID" \
            --password "$ARM_CLIENT_SECRET" \
            --tenant "$ARM_TENANT_ID" \
            --output none
      fi

      #Check if never run before, otherwise update the SSH key
      CONF_EXIST=$(az k8s-configuration flux show -o tsv --query 'name' --name infra-apps-flux-config --cluster-type managedClusters -g ${var.resource_group_name} --cluster-name ${azurerm_kubernetes_cluster.aks.name} --cluster-type managedClusters || true)

      if [ -z $CONF_EXIST ]; then 
        echo "Creating a new GitOps config.." ;
        az k8s-configuration flux create -g ${var.resource_group_name} \
          --cluster-name ${azurerm_kubernetes_cluster.aks.name} \
          --name infra-apps-flux-config --cluster-type managedClusters \
          --sync-interval 30s --ns cluster-config -s cluster \
          -u ${var.git_repo} --branch ${var.git_branch} \
          --ssh-private-key ${var.ssh_priv_key_base64} \
          --kustomization name=infra path=./src/gitops/environments/dev/infra/ prune=true sync_interval=30s \
          --kustomization name=apps path=./src/gitops/environments/dev/apps/ prune=true sync_interval=30s dependsOn=infra \
          --only-show-errors
      else
        echo "Updating existing GitOps config..";
        az k8s-configuration flux update -g ${var.resource_group_name} \
          --cluster-name ${azurerm_kubernetes_cluster.aks.name} \
          --name infra-apps-flux-config --cluster-type managedClusters \
          --sync-interval 30s \
          -u ${var.git_repo} --branch ${var.git_branch} \
          --ssh-private-key ${var.ssh_priv_key_base64} \
          --kustomization name=infra path=./src/gitops/environments/dev/infra/ prune=true sync_interval=30s \
          --kustomization name=apps path=./src/gitops/environments/dev/apps/ prune=true sync_interval=30s dependsOn=infra \
          --only-show-errors
      fi
    EOT
    environment = {
      SSH_PRIV_KEY_BASE64 = var.ssh_priv_key_base64
    }
  }

  depends_on = [
    null_resource.flux-system-exception
  ]
}
