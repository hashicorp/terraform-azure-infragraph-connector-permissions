# Copyright IBM Corp. 2024, 2026

locals {
  assignable_scopes = [
    for id in var.AZURE_SUBSCRIPTION_IDS : "/subscriptions/${id}"
  ]

  # Actions Required for Infragraph to fetch all supported resources
  enabled_actions = [
    # Microsoft.Authorization
    "Microsoft.Authorization/roleAssignments/read",
    "Microsoft.Authorization/roleDefinitions/read",
    # Microsoft.Compute
    "Microsoft.Compute/disks/read",
    "Microsoft.Compute/images/read",
    "Microsoft.Compute/virtualMachines/extensions/read",
    "Microsoft.Compute/virtualMachines/read",
    # Microsoft.ContainerService
    "Microsoft.ContainerService/managedClusters/read",
    # Microsoft.Insights
    "Microsoft.Insights/diagnosticSettings/read",
    # Microsoft.KeyVault
    "Microsoft.KeyVault/vaults/read",
    # Microsoft.ManagedIdentity
    "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/read",
    "Microsoft.ManagedIdentity/userAssignedIdentities/read",
    # Microsoft.Network
    "Microsoft.Network/networkInterfaces/read",
    "Microsoft.Network/networkSecurityGroups/read",
    "Microsoft.Network/networkSecurityGroups/securityRules/read",
    "Microsoft.Network/privateDnsZones/A/read",
    "Microsoft.Network/privateDnsZones/CNAME/read",
    "Microsoft.Network/privateDnsZones/read",
    "Microsoft.Network/privateDnsZones/virtualNetworkLinks/read",
    "Microsoft.Network/privateEndpoints/privateLinkServiceConnections/read",
    "Microsoft.Network/privateEndpoints/read",
    "Microsoft.Network/routeTables/read",
    "Microsoft.Network/routeTables/routes/read",
    "Microsoft.Network/virtualNetworks/read",
    "Microsoft.Network/virtualNetworks/subnets/read",
    # Microsoft.RecoveryServices
    "Microsoft.RecoveryServices/vaults/backupPolicies/read",
    # Microsoft.ResourceGraph
    "Microsoft.ResourceGraph/resources/read",
    # Microsoft.Resources
    "Microsoft.Resources/subscriptions/locations/read",
    "Microsoft.Resources/subscriptions/read",
    "Microsoft.Resources/subscriptions/resourceGroups/read",
    "Microsoft.Resources/tags/read",
    # Microsoft.Sql
    "Microsoft.Sql/servers/databases/read",
    # Microsoft.Web
    "Microsoft.Web/sites/functions/read",
    "Microsoft.Web/sites/read",
  ]
  enabled_data_actions = [
    # Microsoft.KeyVault
    "Microsoft.KeyVault/vaults/secrets/readMetadata/action",
  ]
}