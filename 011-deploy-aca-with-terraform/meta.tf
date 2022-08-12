terraform {
  required_version = "1.2.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.17.0"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}
