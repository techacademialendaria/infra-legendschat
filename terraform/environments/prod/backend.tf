terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstatelibrechat"
    container_name       = "terraform-state"
    key                  = "librechat.prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
