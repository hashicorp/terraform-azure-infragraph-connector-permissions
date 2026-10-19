# Copyright IBM Corp. 2026

variable "HCP_ORG_ID" {
  type = string

  validation {
    condition     = trimspace(var.HCP_ORG_ID) != ""
    error_message = "HCP_ORG_ID must be set to your HCP organization ID."
  }
}

variable "HCP_BASE_URL" {
  type = string

  validation {
    condition     = trimspace(var.HCP_BASE_URL) != ""
    error_message = "HCP_BASE_URL must be set."
  }

  validation {
    condition     = can(regex("^https://", trimspace(var.HCP_BASE_URL)))
    error_message = "HCP_BASE_URL must start with https://"
  }
}

variable "AZURE_SUBSCRIPTION_IDS" {
  type = list(string)

  default = []

  validation {
    condition     = length(var.AZURE_SUBSCRIPTION_IDS) == length(distinct(var.AZURE_SUBSCRIPTION_IDS))
    error_message = "AZURE_SUBSCRIPTION_IDS must not contain duplicates."
  }
 
}

variable "AZURE_CONNECTOR_ROLE_NAME" {
  type        = string
  default     = "infragraph-connector-role"
  description = "Name of the custom Azure role definition created for the Infragraph connector."
}

variable "AZURE_CONNECTOR_APP_NAME" {
  type        = string
  default     = "infragraph-connector"
  description = "Display name of the Entra application registration created for the Infragraph connector."
}


variable "AZURE_MANAGEMENT_GROUP_ID" {
  type    = string
  default = ""

  description = "Management group ID to be used for the Infragraph connector."

}

variable "AZURE_MANAGEMENT_GROUP_CUSTOM_ROLE_NAME" {
  type        = string
  default = "infragraph-connector-management-role"
  description = "Name of the custom Azure role definition used for Infragraph connector actions scoped to a management group."
}

variable "AZURE_MANAGEMENT_GROUP_RESOURCE_CUSTOM_ROLE_NAME" {
  type        = string
  default = "infragraph-connector-resource-read-management-role"
  description = "Name of the custom Azure role definition used by the Infragraph connector for management-group resource read access."
}
