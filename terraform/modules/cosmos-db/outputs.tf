output "id" {
  description = "The ID of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.account.id
}

output "name" {
  description = "The name of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.account.name
}

output "endpoint" {
  description = "The endpoint of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.account.endpoint
}

output "connection_string" {
  description = "The connection string for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.account.connection_strings[0]
  sensitive   = true
}

output "primary_key" {
  description = "The primary key for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.account.primary_key
  sensitive   = true
}

output "database_name" {
  description = "The name of the MongoDB database"
  value       = azurerm_cosmosdb_mongo_database.database.name
}
