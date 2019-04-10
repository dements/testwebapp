provider "azurerm" {
	version = "=1.00.0"
}

# Resource group
resource "azurerm_resource_group" "rg" {
	name = "webapprg"
	location = "westeurope"
}

# Account storage
resource "azurerm_storage_account" "sa" {
	name = "webappsa"
	resource_group_name = "${azurerm_resource_group.rg.name}"
	location = "${azurerm_resource_group.rg.location}"
	account_tier = "Standard"
	account_replication_type = "LRS"

	tags = {
		environment = "development"
	}
}

# Storage container
resource "azurerm_storage_container" "sc" {
	name = "storagecontainer"
	resource_group_name = "${azurerm_resource_group.rg.name}"
	storage_account_name = "${azurerm_storage_account.sa.name}"	
}

# App service plan
resource "azurerm_app_service_plan" "sp" {
	name = "example-appserviceplan"
  	location = "${azurerm_resource_group.rg.location}"
  	resource_group_name = "${azurerm_resource_group.rg.name}"

  	sku {
    	tier = "Standard"
    	size = "S1"
  	}
}

# App service
resource "azurerm_app_service" "as" {
  	name = "example-app-service"
  	location = "${azurerm_resource_group.rg.location}"
  	resource_group_name = "${azurerm_resource_group.rg.name}"
  	app_service_plan_id = "${azurerm_app_service_plan.sp.id}"

  	site_config {
    	python_version = "3.4"
  	}
}

# terraform backend state
data "terraform_remote_state" "tfstate" {
	backend = "azurerm"
	config = {
		resource_group_name = "webapprg"
		storage_account_name = "webappsa"
		container_name = "storagecontainer"
		key = "dev.terraform.tfstate"
	}
}