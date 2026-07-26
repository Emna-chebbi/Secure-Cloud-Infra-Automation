terraform {

  backend "azurerm" {

    resource_group_name  = "tfstate-rg"

    storage_account_name = "tfstatesecureinfra30890"

    container_name       = "tfstate"

    key                  = "secure-cloud-infra.tfstate"

  }

}
