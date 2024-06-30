variable "use_existing_rg" {
  description = "Flag to create resource group within module or Bring Your Own (BYO) resource group"
  type        = bool
  default     = false
}

variable "aa_rg" {
  description = "Name for the resource group, either existing or to be created"
  type        = string
}

variable "location" {
  description = "Azure region where the resources will be created"
  type        = string
}

variable "rg_tags" {
  description = "If creating resource group through module, use this variable to set tags"
  type        = map(any)
  default     = {}
}

variable "use_existing_aa" {
  description = "Flag to create Automation Account within module or Bring Your Own (BYO) automation account"
  type        = bool
  default     = false
}

variable "aa_name" {
  description = "Automation Account name, whether it's an existing one (BYO) or created by the module"
  type        = string
}

variable "aa_sku" {
  description = "Sku for the Automation Account. Used only if Automation Account is created by module. Ignored if using BYO"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Free", "Basic"], var.aa_sku)
    error_message = "The Automation Account sku can be either 'Free' or 'Basic'"
  }
}

variable "aa_tags" {
  description = "Tags to assign to Automation Account."
  type        = map(string)
  default     = {}
}

variable "schedule_name" {
  description = "Name of the schedule used to execute runbook. Defaults to \"bimonthly\""
  type        = string
  default     = "bimonthly"
}

variable "schedule_timezone" {
  description = "Time zone to use for the schedule. Defaults to \"Europe/Paris\"."
  type        = string
  default     = "Europe/Paris"
}

variable "schedule_frequency" {
  description = "Frequency for the schedule. Defaults to \"Month\"."
  type        = string
  default     = "Month"

  validation {
    condition = anytrue([
      var.schedule_frequency == "Day",
      var.schedule_frequency == "Hour",
      var.schedule_frequency == "Month",
      var.schedule_frequency == "Week",

    ])
    error_message = "Accepted values are \"Day\", \"Hour\", \"Month\", \"Week\"."
  }
}

variable "schedule_interval" {
  description = "Specify interval for the selected freauency."
  type        = number
  default     = 2
}

variable "schedule_description" {
  description = "Brief description for the schedule to create for the runbook."
  type        = string
  default     = "Schedule to run every other month."
}

variable "posh_acme_version" {
  description = "Specify posh-acme version to install to automation account."
  type        = string
  default     = "4.22.0"
}

variable "use_existing_kv" {
  description = "Flag to create Key Vault within module or BYO Key Vault."
  type        = bool
  default     = false
}

variable "kv_name" {
  description = "Name of the Keyvault, either existing one or to be created by module"
  type        = string
}

variable "kv_rg" {
  description = "Resource Group name of the existing Keyvault, if using one. This value will be ignored if Keyvault is created by the module (using var.aa_rg value instead)"
  type        = string
  default     = ""

  validation {
    condition     = var.use_existing_kv == true ? length(var.kv_rg) > 0 : true
    error_message = "Empty string value is only valid when using an already existing Key Vault (i.e. when \"use_existing_kv\" variable is set to true )."
  }
}

variable "kv_delete_retention" {
  description = "Set soft delete rentention policy (in days)"
  type        = number
  default     = 7

  validation {
    condition     = contains(range(7, 90), var.kv_delete_retention)
    error_message = "Keyvault soft delete retention must be between 7 and 90 days"
  }
}

variable "kv_purge_protection" {
  description = "Enable Keyvault purge protection"
  type        = bool
  default     = true
}

variable "kv_sku" {
  description = "Specify Key Vault sku."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.kv_sku)
    error_message = "Keyvault sku value can only be 'standard' or 'premium'"
  }
}

variable "certs" {
  description = "object collection for your certificates"
  type = map(object({
    ca            = string #allow only "LE_PROD" or "LE_STAGE"
    dns_zone_name = string #dns zone name (used to grant permission to the dns zone for dns challenge)
    dns_zone_rg   = string #dns zone resource group (used to scope permission to the dns zone only)
    cn            = string #must be an fqdn format. Must include single quotes like so: "'myservice.mydomain.tld'"
    sans          = string #can't be empty string
    contact       = string #check valid email format
  }))

  validation {
    condition     = alltrue([for k, v in var.certs : v.ca == "LE_STAGE"]) || alltrue([for k, v in var.certs : v.ca == "LE_PROD"])
    error_message = "CA can only be \"LE_STAGE\" or \"LE_PROD\"."
  }

  validation {
    condition     = alltrue([for k, v in var.certs : endswith(trim(v.cn, "'"), v.dns_zone_name)])
    error_message = "Certificate CN must match DNS Zone Name."
  }

  validation {
    condition     = alltrue([for k, v in var.certs : endswith(trim(v.sans, "'"), v.dns_zone_name)])
    error_message = "Certificate SANS must match DNS Zone Name."
  }

  validation {
    condition     = alltrue([for k, v in var.certs : length(v.sans) > 0 ])
    error_message = "Certificate must have at least one alternate name (i.e. \"sans\" value can't be empty)."
  }

  validation {
    condition     = alltrue([for k, v in var.certs : startswith(v.cn, "'")]) && alltrue([for k, v in var.certs : endswith(v.sans, "'")])
    error_message = "Certificates SANS and CN must be between single quotes (e.g. \"'www.domain.tld'\")."
  }
}

