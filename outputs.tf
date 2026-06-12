# Copyright IBM Corp. 2024, 2026

output "app_client_id" {
  value       = azuread_application_registration.infragraph_connector.client_id
  description = "Client ID of the Entra application used by the InfraGraph Azure connector"
}

output "role_scope" {
  value       = local.assignable_scopes[0]
  description = "First subscription scope where a connector role is created"
}

output "assignable_scopes" {
  value       = local.assignable_scopes
  description = "Scopes where the connector role is assignable"
}