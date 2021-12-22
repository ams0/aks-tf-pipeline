resource "azurerm_virtual_network" "hub" {
  name                = "${format(var.resource_naming_template, 001, "hub")}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.hub-space
  tags                = var.tags
}

resource "azurerm_subnet" "subnet-hub-fw" {
  name                                           = "subnet-hub-fw"
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.hub.name
  address_prefixes                               = var.hub-fw-subnet-prefix
  enforce_private_link_service_network_policies  = true
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "subnet-hub-private" {
  name                                           = "subnet-hub-private"
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.hub.name
  address_prefixes                               = var.hub-private-subnet-prefix
  enforce_private_link_service_network_policies  = true
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_virtual_network" "spoke" {
  name                = "${format(var.resource_naming_template, 001, "spokes")}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.spoke-space
  tags                = var.tags
}

resource "azurerm_subnet" "subnet-spoke-cluster" {
  name                                           = "subnet-spoke-cluster"
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.spoke.name
  address_prefixes                               = var.subnet-spoke-cluster-prefix
  enforce_private_link_service_network_policies  = true
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "subnet-spoke-ingress" {
  name                                           = "subnet-spoke-ingress"
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.spoke.name
  address_prefixes                               = var.subnet-spoke-ingress-prefix
  enforce_private_link_service_network_policies  = true
  enforce_private_link_endpoint_network_policies = true

}

#Peering Spoke --> Hub
resource "azurerm_virtual_network_peering" "spoke-hub" {
  name                      = "${format(var.resource_naming_template, 001, "spoke-hub")}-peering"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}

#Peering Spoke <-- Hub
resource "azurerm_virtual_network_peering" "hub-spoke" {
  name                      = "${format(var.resource_naming_template, 001, "hub-spoke")}-peering"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
}
