output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

output "eventhub_namespace_name" {
  value = azurerm_eventhub_namespace.iot_eventhub_ns.name
}

output "storage_account_name" {
  value = azurerm_storage_account.iot_blob_storage.name
}

output "cosmosdb_account_name" {
  value = azurerm_cosmosdb_account.iot_cosmosdb.name
}

output "key_vault_name" {
  value = azurerm_key_vault.iot_key_vault.name
}
