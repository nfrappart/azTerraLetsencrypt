variable "use_existing_rg" {
  description = ""
  type        = bool
  default     = false
}

variable "aa_rg" {
  description = "Name for the resource group, either existing or to be created"
  type        = string
}

variable "location" {
  description = ""
  type        = string
}

variable "rg_tags" {
  description = ""
  type        = map(any)
}

variable "use_existing_aa" {
  description = ""
  type        = bool
  default     = false
}

variable "aa_name" {
  description = ""
  type        = string
}

variable "aa_sku" {
  description = ""
  type        = string
  default     = "Basic"
}

variable "aa_tags" {
  description = ""
  type        = map(string)
  default     = {}
}

variable "schedule_name" {
  description = ""
  type        = string
  default     = "bimonthly"
}

variable "schedule_timezone" {
  description = ""
  type        = string
  default     = "Europe/Paris"
}

variable "schedule_frequency" {
  description = ""
  type        = string
  default     = "Month"
}

variable "schedule_interval" {
  description = ""
  type        = number
  default     = 2
}

variable "schedule_description" {
  description = ""
  type        = string
  default     = "Schedule to run every other month."
}

variable "posh_acme_version" {
  description = ""
  type        = string
  default     = "4.22.0"
}

variable "use_existing_kv" {
  description = ""
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
}

variable "kv_delete_retention" {
  description = ""
  type        = number
  default     = 7
}

variable "kv_purge_protection" {
  description = ""
  type        = bool
  default     = true
}

variable "kv_sku" {
  description = ""
  type        = string
  default     = "standard"
}

variable "use_default_pwd" {
  description = ""
  type        = bool
  default     = true
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
}

