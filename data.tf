data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

# Récupération des informations de configuration Azure
data "azurerm_client_config" "current" {}
