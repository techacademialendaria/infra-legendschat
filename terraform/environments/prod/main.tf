locals {
  resource_group_name = "rg-${var.resource_prefix}-${var.environment}"
  vnet_name           = "vnet-${var.resource_prefix}-${var.environment}"
  acr_name            = "acr${var.resource_prefix}${var.environment}"
  cosmos_name         = "cosmos-${var.resource_prefix}-${var.environment}"
  log_analytics_name  = "log-${var.resource_prefix}-${var.environment}"
  container_env_name  = "env-${var.resource_prefix}-${var.environment}"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = var.resource_prefix
    ManagedBy   = "Terraform"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = var.vnet_address_space

  tags = {
    Environment = var.environment
    Project     = var.resource_prefix
    ManagedBy   = "Terraform"
  }
}

# Subnet for Container Apps
resource "azurerm_subnet" "container_apps" {
  name                 = "snet-container-apps"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.container_apps_subnet_cidr]

  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.App/containerApps"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Subnet for Data Services
resource "azurerm_subnet" "data_services" {
  name                 = "snet-data-services"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.data_services_subnet_cidr]
}

# Container Registry
resource "azurerm_container_registry" "main" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.container_registry_sku
  admin_enabled       = true

  tags = {
    Environment = var.environment
    Project     = var.resource_prefix
    ManagedBy   = "Terraform"
  }
}

# Azure Database for MongoDB
resource "azurerm_cosmosdb_mongo_cluster" "mongodb" {
  name                = local.cosmos_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  administrator_login = "mongodbadmin"

  node_count = 1

  tags = {
    Environment = var.environment
    Project     = var.resource_prefix
    ManagedBy   = "Terraform"
  }
}

# MongoDB Database
resource "azurerm_cosmosdb_mongo_database" "librechat" {
  name                = "librechat"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_mongo_cluster.mongodb.name
}

# Log Analytics Workspace (Limited to 100MB)
resource "azurerm_log_analytics_workspace" "main" {
  name                = local.log_analytics_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 7
  daily_quota_gb      = 0.1  # 100MB limit

  tags = {
    Environment = var.environment
    Project     = var.resource_prefix
    ManagedBy   = "Terraform"
  }
}

# Storage Account for Loki
resource "azurerm_storage_account" "loki" {
  name                     = "st${var.resource_prefix}${var.environment}loki"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = {
    Environment = var.environment
    Project     = var.resource_prefix
    ManagedBy   = "Terraform"
  }
}

# Storage Container for Loki
resource "azurerm_storage_container" "loki" {
  name                  = "loki-logs"
  storage_account_name  = azurerm_storage_account.loki.name
  container_access_type = "private"
}

# Container Apps Environment
resource "azurerm_container_app_environment" "main" {
  name                       = local.container_env_name
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  infrastructure_subnet_id = azurerm_subnet.container_apps.id

  tags = {
    Environment = var.environment
    Project     = var.resource_prefix
    ManagedBy   = "Terraform"
  }
}

# API Container App (Private)
module "api_app" {
  source = "../../modules/container-app"

  name                         = "api-${var.environment}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  container_app_environment_id = azurerm_container_app_environment.main.id
  image                        = "mcr.microsoft.com/azure-functions/node:4-node18"
  cpu                          = 1.0
  memory                       = "2Gi"
  min_replicas                 = 1
  max_replicas                 = 5
  is_ingress_public            = false

  environment_variables = {
    NODE_ENV = "production"
  }

  secrets = {
    MONGODB_CONNECTION_STRING = "mongodb://${azurerm_cosmosdb_mongo_cluster.mongodb.administrator_login}:${azurerm_cosmosdb_mongo_cluster.mongodb.administrator_login_password}@${azurerm_cosmosdb_mongo_cluster.mongodb.connection_strings[0]}"
  }
}

# Client Container App (Public)
module "client_app" {
  source = "../../modules/container-app"

  name                         = "client-${var.environment}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  container_app_environment_id = azurerm_container_app_environment.main.id
  image                        = "nginx:alpine"
  cpu                          = 0.5
  memory                       = "1Gi"
  min_replicas                 = 1
  max_replicas                 = 3
  is_ingress_public            = true

  environment_variables = {
    API_URL = module.api_app.url
  }
}

# Meilisearch Container App (Private)
module "meilisearch_app" {
  source = "../../modules/container-app"

  name                         = "meilisearch-${var.environment}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  container_app_environment_id = azurerm_container_app_environment.main.id
  image                        = "getmeili/meilisearch:latest"
  cpu                          = 1.0
  memory                       = "2Gi"
  min_replicas                 = 1
  max_replicas                 = 3
  is_ingress_public            = false

  environment_variables = {
    MEILI_MASTER_KEY = "your-meilisearch-master-key"
  }
}
