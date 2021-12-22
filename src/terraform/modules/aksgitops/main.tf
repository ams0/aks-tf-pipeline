provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_cluster" "aks" {

  #checkov:skip=CKV_AZURE_4:Ensure AKS logging to Azure Monitoring is Configured
  #checkov:skip=CKV_AZURE_117:Ensure that AKS uses disk encryption set
  #checkov:skip=CKV_AZURE_115:Ensure that AKS enables private clusters

  name                            = format(var.resource_naming_template, 001, "aks")
  location                        = var.location
  resource_group_name             = var.resource_group_name
  dns_prefix                      = format(var.resource_naming_template, 001, "aks")
  kubernetes_version              = var.kubernetes_version
  sku_tier                        = var.sku_tier
  api_server_authorized_ip_ranges = []

  automatic_channel_upgrade = var.upgrade_channel

  local_account_disabled = true

  default_node_pool {
    name                   = "defaultpool"
    node_count             = var.defaultpool_node_count
    vm_size                = var.defaultpool_vm_size
    vnet_subnet_id         = var.vnet_subnet_id
    enable_host_encryption = true
    availability_zones     = []
    enable_auto_scaling    = false


  }

  addon_profile {
    oms_agent {
      enabled = var.addon_oms_agent_enabled
    }
    azure_policy {
      enabled = var.addon_azure_policy_enabled
    }

    azure_keyvault_secrets_provider {
      enabled = var.addon_azure_keyvault_secrets_provider_enabled
    }

  }

  dynamic "identity" {
    for_each = var.cluster_identity_type == "SystemAssigned" ? [1] : []
    content {
      type = var.cluster_identity_type
    }
  }

  dynamic "identity" {
    for_each = var.cluster_identity_type == "UserAssigned" ? [1] : []
    content {
      type                      = var.cluster_identity_type
      user_assigned_identity_id = var.user_assigned_identity_id
    }
  }


  network_profile {
    network_plugin    = var.network_plugin
    network_policy    = var.network_policy
    outbound_type     = var.outbound_type
    load_balancer_sku = "Standard"

    service_cidr       = var.service_cidr
    docker_bridge_cidr = var.docker_bridge_cidr
    dns_service_ip     = var.dns_service_ip
  }

  role_based_access_control {
    azure_active_directory {
      managed                = true
      tenant_id              = var.tenant_id
      admin_group_object_ids = var.admin_group_object_ids
      azure_rbac_enabled     = false #this to allow az aks command invoke. Doesn't work without
    }
    enabled = true
  }


  tags = var.tags

  lifecycle {
    ignore_changes = [
      network_profile,
      default_node_pool
    ]
  }
}

resource "null_resource" "enable-pod-identity" {

  count = var.enable_pod_identity != false ? 1 : 0

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

      az aks update -g ${var.resource_group_name} -n ${azurerm_kubernetes_cluster.aks.name} --enable-pod-identity
    EOT

  }

  depends_on = [
    null_resource.install_extension,
    azurerm_kubernetes_cluster.aks
  ]
}
