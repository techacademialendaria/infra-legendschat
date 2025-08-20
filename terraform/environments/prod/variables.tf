variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "Brazil South"
}

variable "resource_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "librechat"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "container_apps_subnet_cidr" {
  description = "CIDR for Container Apps subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "data_services_subnet_cidr" {
  description = "CIDR for Data Services subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "mongodb_admin_password" {
  description = "Administrator password for MongoDB cluster"
  type        = string
  sensitive   = true
}

variable "container_registry_sku" {
  description = "SKU for Container Registry"
  type        = string
  default     = "Basic"
}

variable "log_analytics_sku" {
  description = "SKU for Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}
