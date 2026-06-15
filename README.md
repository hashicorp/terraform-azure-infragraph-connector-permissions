# Terraform Infragraph Azure Connector Module

This module creates the Azure Entra application registration, federated identity credential, service principal, custom role definitions, and role assignments needed for HCP Infragraph to authenticate with Azure and read supported Azure resources.

## What This Module Creates

- An Azure Entra application registration for the Infragraph connector
- A federated identity credential that trusts the HCP OIDC issuer and audience
- An Azure service principal for the application registration
- A custom role definition in each target subscription
- A role assignment that binds the custom role to the connector principal

## Usage

```hcl
module "infragraph_azure_connector" {
  source = "hashicorp/infragraph-connector-permissions/azure"

  HCP_ORG_ID             = "<your-hcp-org-id>"
  HCP_BASE_URL           = "https://<your-hcp-base-url>"
  AZURE_SUBSCRIPTION_IDS = ["<sub-id-1>", "<sub-id-2>"]
}
```

After `terraform apply`, use the exported `app_client_id` when configuring the Azure connector in HCP Infragraph.

## Provider Configuration

Configure `azurerm` and `azuread` in the calling root module.

## Installed Azure Permissions

The generated custom role includes the permission groups listed below.

| Runtime step | API family | Permissions |
|---|---|---|
| Query inventory | Resource Graph | `Microsoft.ResourceGraph/resources/read` |
| Resolve subscription metadata | ARM Resources | `Microsoft.Resources/subscriptions/read`, `Microsoft.Resources/subscriptions/locations/read`, `Microsoft.Resources/subscriptions/resourceGroups/read`, `Microsoft.Resources/tags/read` |
| Read security and identity resources | ARM Authorization + ManagedIdentity | **Authorization:** `Microsoft.Authorization/roleAssignments/read`, `Microsoft.Authorization/roleDefinitions/read`<br>**ManagedIdentity:** `Microsoft.ManagedIdentity/userAssignedIdentities/read`, `Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/read` |
| Read service-level resources | ARM provider reads + data plane | **Compute:** `Microsoft.Compute/disks/read`, `Microsoft.Compute/images/read`, `Microsoft.Compute/virtualMachines/read`, `Microsoft.Compute/virtualMachines/extensions/read`, `Microsoft.ContainerService/managedClusters/read`<br>**Network:** `Microsoft.Network/networkInterfaces/read`, `Microsoft.Network/networkSecurityGroups/read`, `Microsoft.Network/networkSecurityGroups/securityRules/read`, `Microsoft.Network/privateDnsZones/read`, `Microsoft.Network/privateDnsZones/A/read`, `Microsoft.Network/privateDnsZones/CNAME/read`, `Microsoft.Network/privateDnsZones/virtualNetworkLinks/read`, `Microsoft.Network/privateEndpoints/read`, `Microsoft.Network/privateEndpoints/privateLinkServiceConnections/read`, `Microsoft.Network/routeTables/read`, `Microsoft.Network/routeTables/routes/read`, `Microsoft.Network/virtualNetworks/read`, `Microsoft.Network/virtualNetworks/subnets/read`<br>**App and data:** `Microsoft.KeyVault/vaults/read`, `Microsoft.KeyVault/vaults/secrets/readMetadata/action`, `Microsoft.RecoveryServices/vaults/backupPolicies/read`, `Microsoft.Sql/servers/databases/read`, `Microsoft.Web/sites/read`, `Microsoft.Web/sites/functions/read`, `Microsoft.Insights/diagnosticSettings/read` |

## Inputs

- `HCP_ORG_ID`: Required. HCP organization ID used to build the OIDC issuer and redirect URI.
- `HCP_BASE_URL`: Required. Base URL for HCP, such as `https://api.cloud.hashicorp.com`.
- `AZURE_SUBSCRIPTION_IDS`: Required. One or more Azure subscription IDs where the custom role and assignment are created.
- `AZURE_CONNECTOR_ROLE_NAME`: Optional. Defaults to `infragraph-connector-role`.
- `AZURE_CONNECTOR_APP_NAME`: Optional. Defaults to `infragraph-connector`.

## Outputs

- `app_client_id`: Azure application client ID for the connector.
- `role_scope`: First subscription scope where the connector role is created.
- `assignable_scopes`: Subscription scopes where the connector role is assignable.

## Where The Azure Permissions Live

The source of truth for the installed Azure resource permissions is `locals.tf`.

If you need the exact Azure actions this module installs, open `locals.tf` and review `local.enabled_actions` and `local.enabled_data_actions`.
