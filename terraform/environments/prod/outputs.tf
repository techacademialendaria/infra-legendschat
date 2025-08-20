output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "container_registry_name" {
  description = "Name of the container registry"
  value       = azurerm_container_registry.main.name
}

output "container_registry_login_server" {
  description = "Login server URL of the container registry"
  value       = azurerm_container_registry.main.login_server
}

output "mongodb_cluster_name" {
  description = "Name of the MongoDB cluster"
  value       = azurerm_cosmosdb_mongo_cluster.mongodb.name
}

output "mongodb_connection_string" {
  description = "Connection string for MongoDB"
  value       = azurerm_cosmosdb_mongo_cluster.mongodb.connection_strings[0]
  sensitive   = true
}

output "mongodb_database_name" {
  description = "Name of the MongoDB database"
  value       = azurerm_cosmosdb_mongo_database.librechat.name
}

output "storage_account_name" {
  description = "Name of the Storage Account for Loki"
  value       = azurerm_storage_account.loki.name
}

output "storage_account_key" {
  description = "Primary key of the Storage Account"
  value       = azurerm_storage_account.loki.primary_access_key
  sensitive   = true
}

output "loki_container_name" {
  description = "Name of the Loki storage container"
  value       = azurerm_storage_container.loki.name
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "container_app_environment_name" {
  description = "Name of the Container App environment"
  value       = azurerm_container_app_environment.main.name
}

output "container_app_environment_id" {
  description = "ID of the Container App environment"
  value       = azurerm_container_app_environment.main.id
}

output "api_app_name" {
  description = "Name of the API Container App"
  value       = module.api_app.name
}

output "api_app_url" {
  description = "URL of the API Container App"
  value       = module.api_app.url
}

output "client_app_name" {
  description = "Name of the Client Container App"
  value       = module.client_app.name
}

output "client_app_url" {
  description = "URL of the Client Container App"
  value       = module.client_app.url
}

output "meilisearch_app_name" {
  description = "Name of the Meilisearch Container App"
  value       = module.meilisearch_app.name
}

output "meilisearch_app_url" {
  description = "URL of the Meilisearch Container App"
  value       = module.meilisearch_app.url
}
