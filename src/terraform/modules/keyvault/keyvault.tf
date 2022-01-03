data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                        = replace(format(var.resource_naming_template, var.progressive, "kv"), "-", "")
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  tags                        = var.tags
  sku_name                    = var.sku_name

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Update"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Purge"
    ]
  }

  network_acls {
    default_action = "Allow"
    bypass         = "None"
    # virtual_network_subnet_ids = [var.subnet_id]
  }
}

## Private endpoint config
resource "azurerm_private_endpoint" "kv-endpoint" {
  name                = "kv-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "kv-private-service-connection"
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "kv-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv-zone.id]
  }

  depends_on = [
    azurerm_private_dns_zone.kv-zone
  ]
}

resource "azurerm_private_dns_zone" "kv-zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv-zone-dns-link" {
  name                  = "kv-zone-dns-zone-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.kv-zone.name
  virtual_network_id    = var.private_vnet_id
  tags                  = var.tags
}

# Predefined secrets for keycloak
