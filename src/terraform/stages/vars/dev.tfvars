nodepools = [
  {
    name              = "gp0",
    vmsize            = "Standard_B4ms",
    nodecount         = 2,
    max_count         = 4,
    min_count         = 2,
    k8s_version       = "1.22.2",
    priority          = "Regular",
    vnet_subnet_id    = "/subscriptions/12c7e9d6-967e-40c8-8b3e-4659a4ada3ef/resourceGroups/westeurope-dev-1-aks-tf-rg/providers/Microsoft.Network/virtualNetworks/westeurope-dev-1-aks-spokes-vnet/subnets/subnet-spoke-cluster"
    enable_autoscaler = true
    node_labels       = { type = "general_purpose", autoscaling = "on" },
    node_taints       = [],
  }
]
