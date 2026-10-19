# Copyright IBM Corp. 2026

output "app_client_id" {
  value       = azuread_application_registration.infragraph_connector.client_id
  description = "Client ID of the Entra application used by the Infragraph Azure connector"
}

output "role_scope" {
  value       = try(local.assignable_scopes[0], local.management_group_scopes[0])
  description = "Target role scope derived from the first AZURE_SUBSCRIPTION_IDS entry or AZURE_MANAGEMENT_GROUP_ID"
}

output "assignable_scopes" {
  value       = length(local.assignable_scopes) > 0 ? local.assignable_scopes : local.management_group_scopes
  description = "Scopes where the connector role is assignable"
}