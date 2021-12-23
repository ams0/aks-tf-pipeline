#resource "random_password" "keycloak_password" {
#     length           = 16
#     special          = true
#     override_special = "_%@"
#     min_numeric      = 2
#     upper            = true
#     min_upper        = 2
#     lower            = true
#     min_lower        = 2
#   }

#   resource "random_string" "keycloak_login" {
#     length  = 16
#     special = false
#   }

#   resource "time_static" "now" {}

#   resource "azurerm_key_vault_secret" "keycloak_username" {
#     name            = "keycloak-username"
#     value           = random_string.keycloak_login.result
#     key_vault_id    = azurerm_key_vault.keyvault.id
#     tags            = { secret = false }
#     expiration_date = timeadd(time_static.now.rfc3339, "2160h")

#     lifecycle {
#       ignore_changes = [
#         not_before_date,
#         expiration_date
#       ]
#     }
#   }

#   resource "azurerm_key_vault_secret" "keycloak_password" {
#     name            = "keycloak-password"
#     value           = random_password.keycloak_password.result
#     key_vault_id    = azurerm_key_vault.keyvault.id
#     tags            = { secret = true }
#     expiration_date = timeadd(time_static.now.rfc3339, "2160h")

#     lifecycle {
#       ignore_changes = [
#         not_before_date,
#         expiration_date
#       ]
#     }
#   }
