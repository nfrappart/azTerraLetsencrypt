variable "use_existing_rg" {
  description = ""
  type        = bool
  default     = false
}

variable "rg_name" {
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

variable "use_existing_schedule" {
  description = ""
  type        = bool
  default     = false
}
