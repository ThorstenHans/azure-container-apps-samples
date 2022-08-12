resource "azurerm_resource_group" "rg" {
  name     = "rg-aca-terraform"
  location = var.location
  tags     = local.tags
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-aca-terraform"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku               = "PerGB2018"
  retention_in_days = 90

  tags = local.tags
}
