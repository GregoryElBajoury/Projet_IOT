# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_cluster_name
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  dns_prefix          = "iotaks"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  sku_tier = "Standard"

}

# Event Hub Namespace
resource "azurerm_eventhub_namespace" "iot_eventhub_ns" {
  name                = var.eventhub_namespace
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  sku                 = "Standard"
}

# Event Hub Instance
resource "azurerm_eventhub" "iot_eventhub" {
  name                = "iot-eventhub"
  namespace_name      = azurerm_eventhub_namespace.iot_eventhub_ns.name
  resource_group_name = data.azurerm_resource_group.existing.name
  partition_count     = 2
  message_retention   = 7

  depends_on = [
    azurerm_eventhub_namespace.iot_eventhub_ns
  ]
}

# Azure Blob Storage Account
resource "azurerm_storage_account" "iot_blob_storage" {
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.existing.name
  location                 = data.azurerm_resource_group.existing.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  depends_on = [
    azurerm_key_vault.iot_key_vault
  ]
}

# Cosmos DB Account
resource "azurerm_cosmosdb_account" "iot_cosmosdb" {
  name                = var.cosmosdb_account_name
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = "North Europe"
    failover_priority = 0
  }
}

# Key Vault for Secrets
resource "azurerm_key_vault" "iot_key_vault" {
  name                = "iot-keyvault-g123"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

# Role Assignment for Key Vault Access
resource "azurerm_role_assignment" "kv_role" {
  scope                = azurerm_key_vault.iot_key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id

  depends_on = [
    azurerm_kubernetes_cluster.aks_cluster,
    azurerm_key_vault.iot_key_vault
  ]
}
