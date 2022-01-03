resource "azurerm_kubernetes_cluster_node_pool" "pools" {

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }

  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id

  count                = length(var.nodepools)
  name                 = var.nodepools[count.index].name
  vm_size              = var.nodepools[count.index].vmsize
  node_count           = var.nodepools[count.index].nodecount
  max_count            = var.nodepools[count.index].max_count
  min_count            = var.nodepools[count.index].min_count
  orchestrator_version = var.nodepools[count.index].k8s_version
  priority             = var.nodepools[count.index].priority
  eviction_policy      = var.nodepools[count.index].eviction_policy
  availability_zones   = var.nodepools[count.index].availability_zones

  vnet_subnet_id       = var.vnet_subnet_id
  #vnet_subnet_id      = var.nodepools[count.index].vnet_subnet_id
  enable_auto_scaling = var.nodepools[count.index].enable_auto_scaling

  node_labels = var.nodepools[count.index].node_labels

  node_taints = var.nodepools[count.index].node_taints

  tags = var.tags

}
