data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                        = replace(format(var.resource_naming_template, 001, "kv"), "-", "")
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
resource "random_password" "keycloak_password" {
  length           = 16
  special          = true
  override_special = "_%@"
  min_numeric      = 2
  upper            = true
  min_upper        = 2
  lower            = true
  min_lower        = 2
}

resource "random_string" "keycloak_login" {
  length  = 16
  special = false
}

resource "time_static" "now" {}

resource "azurerm_key_vault_secret" "keycloak_username" {
  name            = "keycloak-username"
  value           = random_string.keycloak_login.result
  key_vault_id    = azurerm_key_vault.keyvault.id
  tags            = { secret = false }
  expiration_date = timeadd(time_static.now.rfc3339, "2160h")

  lifecycle {
    ignore_changes = [
      not_before_date,
      expiration_date
    ]
  }
}

resource "azurerm_key_vault_secret" "keycloak_password" {
  name            = "keycloak-password"
  value           = random_password.keycloak_password.result
  key_vault_id    = azurerm_key_vault.keyvault.id
  tags            = { secret = true }
  expiration_date = timeadd(time_static.now.rfc3339, "2160h")

  lifecycle {
    ignore_changes = [
      not_before_date,
      expiration_date
    ]
  }
}
