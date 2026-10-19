# Copyright IBM Corp. 2026
# SPDX-License-Identifier: MPL-2.0

provider "azuread" {}

provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
}