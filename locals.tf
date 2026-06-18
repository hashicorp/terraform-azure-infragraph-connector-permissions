# Copyright IBM Corp. 2024, 2026

locals {
  # Management_group id set to be used (only set if subscription_ids not provided)
  management_group_assignment_ids = toset(
    length(var.AZURE_SUBSCRIPTION_IDS) == 0 ? var.AZURE_MANAGEMENT_GROUP_IDS : []
  )

  assignable_scopes = [
    for id in var.AZURE_SUBSCRIPTION_IDS : "/subscriptions/${id}"
  ]
  # scope for management-group
  management_group_scopes = [
    for id in var.AZURE_MANAGEMENT_GROUP_IDS : "/providers/Microsoft.Management/managementGroups/${id}"
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
  enabled_management_actions = [
    #Microsoft.Management
    "Microsoft.Management/managementGroups/read",
    #Microsoft.Resource
    "Microsoft.Resources/subscriptions/read",
  ]
}