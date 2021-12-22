# Azure Kubernetes Cluster Terraform module

This module installs an AKS cluster complete with multiple nodepools, AAD Pod Identity (via Helm) and CSI Secret store driver (both are not yet in the `azurerm_kubernetes_cluster` resource).

## Prereqs:

Register this features and providers in your Azure subscription:

```
az feature register --namespace Microsoft.ContainerService --name AKS-ExtensionManager
az feature register --namespace Microsoft.KubernetesConfiguration --name fluxConfigurations
```

Allow about 30 minutes for the features to be registered and then re-register the providers:

```
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.KubernetesConfiguration
```

## Parameters:

The module expects:

- `resource_group_name` An existing resource group name to be imported as data
- `name` Cluster name, will be also the cluster DNS name
- `upgrade_channel` Default to stable
- `defaultpool_node_count` and `defaultpool_vm_size` Default to 3 and Standard_B4ms
- `kubernetes_version` Defaults to 1.22.2
- `tenant_id` and `admin_group_object_ids` AAD tenant and admin group ID for AAD authentication. 
- One `user_assigned_identity_id` (in the form `/subscriptions/<sub_id>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<mi_name>`) that points to the cluster identity
- One `kubelet_user_assigned_identity_id` with `client_id` and `object_id` that points to the Kubelet managed identity
- `tags` A list of tags

Networking:

- `outbound_type` Default to LoadBalancer, but `managedNATGateway` is possible (only when no [custom VNET are used](https://github.com/MicrosoftDocs/azure-docs/issues/83858))
- `vnet_subnet_id` A subnet ID where the first nodepool will be deployed into
- `network_policy` The network policy, defaults to `calico`
- `network_plugin` The network plugin, `azure` or `kubenet` (default)
 
Addons:
- `addon_azure_keyvault_secrets_provider` set to true to install the CSI Keyvault Secret provider
- `addon_oms_agent_enabled` set to true to install the Azure Monitor agent
- `addon_azure_policy_enabled` set to true to install the Azure policy agent
- 
For the GitOps part:

- `ssh_priv_key_base64` A base64 encoded private key added to Azure DevOps with the ability to clone the gitops repo
- `git_repo` The repository URL, in the form `ssh://git@ssh.dev.azure.com/v3/org/project/repo`
- `git_branch` The branch to use

## What does this module do:

The module will deploy an AKS cluster with:

- AAD integration 
- Local accounts disabled
- Host encrpytion
- Pod Identity (enabled after the cluster is created)
- GitOps Flux v2 configuration, pointing to a repo/branch of choice. An SSH key (in base64) is needed to access the Azure DevOps private repo containing the manifests
- Two Kustomizations: one for `infra` (pointing to the path `/src/gitops/infra`) and for `apps` (`/src/gitops/apps`), the latter depending on the successfull application of the former.
  
## Additional nodepools

You can define arbitrary nodepools like this:

```
nodepools = [
  {
    name        = "gp0",
    vmsize      = "Standard_B4ms",
    nodecount   = 2,
    max_count   = 4,
    min_count   = 2,
    k8s_version = "1.22.2",
    priority    = "Regular",
    vnet_subnet_id = "<subnet_id>"
    enable_autoscaler = true
    node_labels = { type = "general_purpose", autoscaling = "on" },
    node_taints = [],
  }
]
```

