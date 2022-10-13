terraform {
  required_version = "~>1.3.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.26.0"
    }
    azapi = {
      source = "Azure/azapi"
      version = "~>1.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}
