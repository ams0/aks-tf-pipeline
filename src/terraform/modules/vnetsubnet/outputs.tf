output "vnet_hub_name" {
  value = azurerm_virtual_network.hub.name
}

output "vnet_hub_id" {
  value = azurerm_virtual_network.hub.id
}

output "vnet_spoke_name" {
  value = azurerm_virtual_network.spoke.name
}

output "vnet_spoke_id" {
  value = azurerm_virtual_network.spoke.id
}