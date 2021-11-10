terraform {
  required_providers {
      azurerm = {
          source = "hashicorp/azurerm"
          version = ">=2.64.0, <3.0.0"
      }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  location = "westus2"
  name = "DevOpsTestingFunctionalTesting"
  tags = {status = "temporary", project = "ADO Functional Tests"}
}

resource "random_id" "randomId" {
  keepers = {
    resource_group = azurerm_resource_group.rg.name
  }
  byte_length = 8
}

resource "azurerm_app_service_plan" "example" {
  location = azurerm_resource_group.rg.location
  name = "FunctionalTesting${substr(random_id.randomId.hex, 0, 6)}"
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = "Standard"
    size = "S1"
  }
  tags = azurerm_resource_group.rg.tags
}

resource "azurerm_app_service" "example_web_game" {
  app_service_plan_id = azurerm_app_service_plan.example.id
  location = azurerm_resource_group.rg.location
  name = "WebGameExample${substr(random_id.randomId.hex, 0, 6)}"
  resource_group_name = azurerm_resource_group.rg.name
  tags = azurerm_resource_group.rg.tags
  
  app_settings = {
  }

  site_config {
    dotnet_framework_version = "V5.0"
    ip_restriction = []
  }
}

resource "azurerm_app_service_slot" "example_web_game_1" {
  name = "slot1-${random_id.randomId.hex}"
  app_service_name = azurerm_app_service.example_web_game.name
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.example.id
  site_config {
    dotnet_framework_version = "V5.0"
    ip_restriction = []
  }
}
