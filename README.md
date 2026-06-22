# Terraform Infragraph Azure Connector Module

This module creates the Azure Entra application registration, federated identity credential, service principal, custom role definitions, and role assignments needed for HCP Infragraph to authenticate with Azure and read supported Azure resources.

## What This Module Creates

- An Azure Entra application registration for the Infragraph connector
- A federated identity credential that trusts the HCP OIDC issuer and audience
- An Azure service principal for the application registration
- Custom role definitions in each target subscription or management group
- Role assignments that bind the custom roles to the connector principal
- A built-in `Key Vault Reader` role assignment at management-group scope

## Usage

```hcl
module "infragraph_azure_connector" {
  source = "hashicorp/infragraph-connector-permissions/azure"

  HCP_ORG_ID                   = "<your-hcp-org-id>"
  HCP_BASE_URL                 = "https://<your-hcp-base-url>"
  AZURE_SUBSCRIPTION_IDS       = ["<sub-id-1>", "<sub-id-2>"]
  AZURE_MANAGEMENT_GROUP_ID    = "<management-id>"
}
```
Note: Specify either AZURE_SUBSCRIPTION_IDS or AZURE_MANAGEMENT_GROUP_ID, but not both

You can override the custom role-defintion names and app registration name by including the role definition variable as well with the above section

eg:
```
AZURE_CONNECTOR_ROLE_NAME                        = "<your custome name for subscription scope role>

AZURE_MANAGEMENT_GROUP_CUSTOM_ROLE_NAME          = "<yuour custome name for management specific read role>"

AZURE_MANAGEMENT_GROUP_RESOURCE_CUSTOM_ROLE_NAME = "<yuour custome name for management group scope Resource read role>"

AZURE_CONNECTOR_APP_NAME                         = "<your custome name foor app registration>"


```

After `terraform apply`, use the exported `app_client_id` when configuring the Azure connector in HCP Infragraph.

## Provider Configuration

Configure `azurerm` and `azuread` in the calling root module.

## Installed Azure Permissions

The generated custom roles include the permission groups listed below.

### Subscription-scope role (`AZURE_CONNECTOR_ROLE_NAME`)

Applied when `AZURE_SUBSCRIPTION_IDS` is set.

| Runtime step | API family | Permissions |
|---|---|---|
| Query inventory | Resource Graph | `Microsoft.ResourceGraph/resources/read` |
| Resolve subscription metadata | ARM Resources | `Microsoft.Resources/subscriptions/read`, `Microsoft.Resources/subscriptions/locations/read`, `Microsoft.Resources/subscriptions/resourceGroups/read`, `Microsoft.Resources/tags/read` |
| Read security and identity resources | ARM Authorization + ManagedIdentity | **Authorization:** `Microsoft.Authorization/roleAssignments/read`, `Microsoft.Authorization/roleDefinitions/read`<br>**ManagedIdentity:** `Microsoft.ManagedIdentity/userAssignedIdentities/read`, `Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/read` |
| Read service-level resources | ARM provider reads + data plane | **Compute:** `Microsoft.Compute/disks/read`, `Microsoft.Compute/images/read`, `Microsoft.Compute/virtualMachines/read`, `Microsoft.Compute/virtualMachines/extensions/read`, `Microsoft.ContainerService/managedClusters/read`<br>**Network:** `Microsoft.Network/networkInterfaces/read`, `Microsoft.Network/networkSecurityGroups/read`, `Microsoft.Network/networkSecurityGroups/securityRules/read`, `Microsoft.Network/privateDnsZones/read`, `Microsoft.Network/privateDnsZones/A/read`, `Microsoft.Network/privateDnsZones/CNAME/read`, `Microsoft.Network/privateDnsZones/virtualNetworkLinks/read`, `Microsoft.Network/privateEndpoints/read`, `Microsoft.Network/privateEndpoints/privateLinkServiceConnections/read`, `Microsoft.Network/routeTables/read`, `Microsoft.Network/routeTables/routes/read`, `Microsoft.Network/virtualNetworks/read`, `Microsoft.Network/virtualNetworks/subnets/read`<br>**App and data:** `Microsoft.KeyVault/vaults/read`, `Microsoft.KeyVault/vaults/secrets/readMetadata/action`, `Microsoft.RecoveryServices/vaults/backupPolicies/read`, `Microsoft.Sql/servers/databases/read`, `Microsoft.Web/sites/read`, `Microsoft.Web/sites/functions/read`, `Microsoft.Insights/diagnosticSettings/read` |

### Management-group-scope roles (`AZURE_MANAGEMENT_GROUP_CUSTOM_ROLE_NAME` and `AZURE_MANAGEMENT_GROUP_RESOURCE_CUSTOM_ROLE_NAME`)

Applied when `AZURE_MANAGEMENT_GROUP_ID` is set and `AZURE_SUBSCRIPTION_IDS` is empty.

| Role | API family | Permissions |
|---|---|---|
| Management group access (`AZURE_MANAGEMENT_GROUP_CUSTOM_ROLE_NAME`) | ARM Management | `Microsoft.Management/managementGroups/read`, `Microsoft.Resources/subscriptions/read` |
| Resource read access (`AZURE_MANAGEMENT_GROUP_RESOURCE_CUSTOM_ROLE_NAME`) | ARM provider reads + data plane | Same full permission set as the subscription-scope role above (Except data_actions: `Microsoft.KeyVault/vaults/secrets/readMetadata/action`) |
| Key Vault secret metadata access | Built-in role assignment | `Key Vault Reader` |

## Inputs

- `HCP_ORG_ID`: Required. HCP organization ID used to build the OIDC issuer and redirect URI.
- `HCP_BASE_URL`: Required. Base URL for HCP, such as `https://api.cloud.hashicorp.com`. Must start with `https://`.
- `AZURE_SUBSCRIPTION_IDS`: Optional. One or more Azure subscription IDs where the custom role and assignment are created. Defaults to `[]`. No duplicates allowed.
- `AZURE_MANAGEMENT_GROUP_ID`: Optional. Azure management group ID where the custom role and assignment are created. Defaults to `""`.
- `AZURE_CONNECTOR_ROLE_NAME`: Optional. Name of the custom role created for subscription-level (and management-group resource-read) access. Defaults to `infragraph-connector-role`.
- `AZURE_MANAGEMENT_GROUP_CUSTOM_ROLE_NAME`: Optional. Name of the custom role created for management-group-level access. Defaults to `infragraph-connector-management-role`.
- `AZURE_MANAGEMENT_GROUP_RESOURCE_CUSTOM_ROLE_NAME`: Optional. Name of the custom role created for management-group resource-read access. Defaults to `infragraph-connector-resource-read-management-role`.
- `AZURE_CONNECTOR_APP_NAME`: Optional. Display name of the Entra application registration. Defaults to `infragraph-connector`.

## Outputs

- `app_client_id`: Azure application client ID for the connector.
- `role_scope`: First scope (subscription or management-group) where the connector role is created.
- `assignable_scopes`: Preferred scopes where the connector role is assignable: subscription scopes when `AZURE_SUBSCRIPTION_IDS` is set, otherwise management group scopes.

## Where The Azure Permissions Live

The source of truth for the installed Azure resource permissions is `locals.tf`.

If you need the exact Azure actions this module installs, open `locals.tf` and review `local.enabled_actions` and `local.enabled_data_actions`.
