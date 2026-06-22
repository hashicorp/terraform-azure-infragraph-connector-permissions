# Copyright IBM Corp. 2024, 2026

# Requires access to edit Entra ID app registrations at tenant level.
resource "azuread_application_registration" "infragraph_connector" {
  display_name     = var.AZURE_CONNECTOR_APP_NAME
  description      = "Infragraph Azure connector application registration"
  sign_in_audience = "AzureADMyOrg"
}

# Register HCP as a redirect URI for OIDC issuer/audience verification.
resource "azuread_application_redirect_uris" "infragraph_public_client" {
  application_id = azuread_application_registration.infragraph_connector.id
  type           = "PublicClient"

  redirect_uris = [
    "${trimsuffix(var.HCP_BASE_URL, "/")}/oidc/organization/${var.HCP_ORG_ID}",
  ]
}

# Trust Infragraph-issued OIDC tokens for this Entra app.
resource "azuread_application_federated_identity_credential" "infragraph_connector" {
  application_id = azuread_application_registration.infragraph_connector.id
  display_name   = "infragraph-azure-connector"
  description    = "Infragraph Azure connector"
  audiences      = ["graph.connector.azure"]
  issuer         = "${trimsuffix(var.HCP_BASE_URL, "/")}/oidc/organization/${var.HCP_ORG_ID}"
  subject        = "project:n/a:geo:geo:service:infragraph:type:integration:name:infragraph"
}

# Principal used by the connector at snapshot runtime.
resource "azuread_service_principal" "infragraph_connector" {
  client_id                    = azuread_application_registration.infragraph_connector.client_id
  app_role_assignment_required = false
}

# Custom role for granular Azure connector read access.
resource "azurerm_role_definition" "infragraph_connector" {
  for_each = toset(var.AZURE_SUBSCRIPTION_IDS)

  name        = var.AZURE_CONNECTOR_ROLE_NAME
  scope       = "/subscriptions/${each.value}"
  description = "Read permissions for the Infragraph Azure connector"

  permissions {
    actions      = local.enabled_actions
    data_actions = local.enabled_data_actions
  }

  assignable_scopes = ["/subscriptions/${each.value}"]
}

# Bind custom role to the connector principal.
resource "azurerm_role_assignment" "infragraph_connector" {
  for_each = toset(var.AZURE_SUBSCRIPTION_IDS)

  scope              = "/subscriptions/${each.value}"
  role_definition_id = azurerm_role_definition.infragraph_connector[each.value].role_definition_resource_id
  principal_id       = azuread_service_principal.infragraph_connector.object_id
}

# Custom role definition at the configured management group scope.
# Applied only when no subscription IDs are provided.
resource "azurerm_role_definition" "infragraph_connector_management_group" {
  count = local.management_group_enabled ? 1 : 0

  name        = var.AZURE_MANAGEMENT_GROUP_CUSTOM_ROLE_NAME
  scope       = local.management_group_scope
  description = "Read permissions for the InfraGraph Azure connector"

  permissions {
    actions = local.enabled_management_actions
  }

  assignable_scopes = [local.management_group_scope]
}

# Bind custom role definition to the configured management group.
# Applied only when no subscription IDs are provided.
resource "azurerm_role_assignment" "infragraph_management_group_custom_role" {
  count = local.management_group_enabled ? 1 : 0

  scope              = local.management_group_scope
  role_definition_id = azurerm_role_definition.infragraph_connector_management_group[0].role_definition_resource_id
  principal_id       = azuread_service_principal.infragraph_connector.object_id
}

# Create custom role for resource access at management group scope.
# Applied only when no subscription IDs are provided.
resource "azurerm_role_definition" "infragraph_connector_management_group_action" {
  count = local.management_group_enabled ? 1 : 0

  name        = var.AZURE_MANAGEMENT_GROUP_RESOURCE_CUSTOM_ROLE_NAME
  scope       = local.management_group_scope
  description = "Read permissions for the InfraGraph Azure connector"

  permissions {
    actions = local.enabled_actions
  }

  assignable_scopes = [local.management_group_scope]
}

# Bind custom role definition for resource access to the configured management group.
# Applied only when no subscription IDs are provided.
resource "azurerm_role_assignment" "infragraph_management_group_subscription_actions_role" {
  count = local.management_group_enabled ? 1 : 0

  scope              = local.management_group_scope
  role_definition_id = azurerm_role_definition.infragraph_connector_management_group_action[0].role_definition_resource_id
  principal_id       = azuread_service_principal.infragraph_connector.object_id

}

# Bind Key Vault Reader(built-in role) access for management-group
# Since data-action can not be assign to managementGroup
resource "azurerm_role_assignment" "infragraph-keyvault-reader" {
  count = local.management_group_enabled ? 1 : 0
  scope              = local.management_group_scope
  role_definition_name = "Key Vault Reader"
  principal_id       = azuread_service_principal.infragraph_connector.object_id
}