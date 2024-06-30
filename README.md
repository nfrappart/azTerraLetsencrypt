# Azure Automation Let's Encrypt Module
This module helps you automate Let's Encrypt certificate issuance and lifecycle. It leverages Posh-acme module with Azure Automation account's runbook. There are several defaulted variables to allow ease of use, but there are options to help you integrate with existing resources.

## Created resources:
- resource group (optional, can use existing one) 
- automation account (optional, can use existing one)
- automation account schedule (defaults to bi-monthly)
- posh-acme automation account powershell module
- keyvault (optional, can use existing one)
- keyvault secret for certificate passphrase
- one or more automation account runbooks (one per object in var.certs)
- Role Assignment (DNS Zone Contributor) for each certificate domain
- Role Assignment (Key Vault Administrator) for the principal running the terraform module

## Required resources :
- existing resource group (if not creating new one)
- existing automation account (if not creating new one)
- existing public DNS zone matching the certificates to be managed

## Usage Example :

```hcl
provider "azurerm" {
  features {}
}

module "le" {
  source  = "ryzhom/letsencrypt/azurerm"
  version = "0.1.0"
  aa_rg                 = "rg-test"
  location              = "francecentral"
  rg_tags               = {}
  aa_name               = "aa-test"
  kv_name               = "kv-for-aa"
  certs                 = {
    www = {
      ca = "LE_STAGE"
      dns_zone_name = "domain.tld"
      dns_zone_rg = "rg-mydnszone"
      cn = "'www.domain.tld'"
      sans = "'web.domain.tld'"
      contact = "contact@domain.tld"
    }
  }
}
```
