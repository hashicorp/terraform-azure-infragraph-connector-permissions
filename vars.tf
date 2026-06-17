# Copyright IBM Corp. 2024, 2026

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

  validation {
    condition     = length(var.AZURE_SUBSCRIPTION_IDS) > 0
    error_message = "AZURE_SUBSCRIPTION_IDS must include at least one subscription ID."
  }

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
