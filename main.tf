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
