data "azurerm_resource_group" "automation" {
  count    = var.use_existing_rg == true ? 1 : 0
  name     = var.rg_name
  location = var.location
}

resource "azurerm_resource_group" "automation" {
  count    = var.use_existing_rg == true ? 0 : 1
  name     = var.rg_name
  location = var.location
  tags     = var.rg_tags
}

data "azurerm_automation_account" "automation" {
  count               = var.use_existing_aa == true ? 1 : 0
  name                = var.aa_name
  resource_group_name = var.aa_rg
}

resource "azurerm_automation_account" "automation" {
  count               = var.use_existing_aa == true ? 0 : 1
  name                = var.aa_name
  resource_group_name = var.use_existing_rg == true ? data.azurerm_resource_group.automation.name : azurerm_resource_group.automation.name
  location            = var.location
  identity {
    type = "SystemAssigned"
  }

  sku_name = var.aa_sku #"Basic"

  tags = var.aa_tags
}

resource "azurerm_automation_schedule" "bimonthly" {
  count                   = var.use_existing_sechedule == true ? 0 : 1
  name                    = "bimonthly"
  resource_group_name     = var.use_existing_rg == true ? data.azurerm_resource_group.automation.name : azurerm_resource_group.automation.name
  automation_account_name = var.use_existing_aa == true ? data.azurerm_automation_account.automation.name : azurerm_automation_account.automation.name
  frequency               = "Month"
  interval                = 2
  timezone                = var.aa_schedule_timezone #"Europe/Paris"
  description             = "Schedule to run every other month."
}


resource "azurerm_automation_powershell72_module" "posh_acme" {
  name                  = "Posh-ACME"
  automation_account_id = azurerm_automation_account.automation.id

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Posh-ACME/4.22.0"
  }
}

resource "random_password" "posh_acme" {
  length           = 16
  special          = true
  override_special = "@!-+[]"
}

resource "azurerm_key_vault_secret" "posh_acme" {
  name         = "posh-acme"
  value        = random_password.posh_acme.result
  key_vault_id = azurerm_key_vault.kv.id

  lifecycle {
    ignore_changes = [value]
  }
}
#resource "azurerm_automation_runbook" "letsencrypt" {
#  name                    = "letsencrypt_www"
#  resource_group_name = azurerm_resource_group.rg["rg-core"].name
#  location            = azurerm_resource_group.rg["rg-core"].location
#  automation_account_name = azurerm_automation_account.automation.name
#  log_verbose             = "false" #"true"
#  log_progress            = "true"
#  description             = "Powershell script using posh-acme to generate letsencrypt certificates"
#  runbook_type            = "PowerShell72"
#
#  content = file("${path.module}/assets/acme_www-dot-ryzhom-dot-com.ps1")#data.local_file.example.content
#}
#
#
#resource "azurerm_automation_job_schedule" "letsencrypt" {
#  resource_group_name = azurerm_resource_group.rg["rg-core"].name
#  automation_account_name = azurerm_automation_account.automation.name
#  schedule_name           = azurerm_automation_schedule.bimonthly.name
#  runbook_name            = azurerm_automation_runbook.letsencrypt.name
#}

locals {
  certs = {
    vault = {
      ca      = "LE_PROD"
      cn      = "'vault.priv.ryzhom.com'"
      sans    = "'vault1.priv.ryzhom.com','vault2.priv.ryzhom.com','vault3.priv.ryzhom.com'"
      contact = "certbot@ryzhom.io"
    },
    consul = {
      ca      = "LE_PROD"
      cn      = "'consul.priv.ryzhom.com'"
      sans    = "'consul1.priv.ryzhom.com','consul2.priv.ryzhom.com','consul3.priv.ryzhom.com'"
      contact = "certbot@ryzhom.io"
    },
    www = {
      ca      = "LE_PROD"
      cn      = "'www.ryzhom.com'"
      sans    = "'ryzhom.com','web.ryzhom.com'"
      contact = "certbot@ryzhom.io"
    },
    aks-nginx-demo = {
      ca      = "LE_PROD"
      cn      = "'aks-nginx-demo.ryzhom.com'"
      sans    = "'nginx-demo.ryzhom.com'"
      contact = "certbot@ryzhom.io"
    },
    whoami = {
      ca      = "LE_PROD"
      cn      = "'whoami.ryzhom.com'"
      sans    = "'aks-whoami.ryzhom.com'"
      contact = "certbot@ryzhom.io"
    }
  }
}

resource "azurerm_automation_runbook" "acme_le" {
  for_each                = local.certs
  name                    = "letsencrypt_${each.key}"
  resource_group_name     = azurerm_resource_group.rg["rg-core"].name
  location                = azurerm_resource_group.rg["rg-core"].location
  automation_account_name = azurerm_automation_account.automation.name
  log_verbose             = "false" #"true"
  log_progress            = "true"
  description             = "Powershell script using posh-acme to generate letsencrypt certificates"
  runbook_type            = "PowerShell72"

  content = templatefile("${path.module}/assets/acme.ps1.tmpl", {
    subid       = data.azurerm_client_config.current.subscription_id,
    ca          = each.value.ca,
    cn          = each.value.cn,
    sans        = each.value.sans,
    contact     = each.value.contact,
    vault_name  = azurerm_key_vault.kv.name,
    secret_name = each.key
  })
}

resource "azurerm_role_assignment" "automation_dns" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_automation_account.automation.identity[0].principal_id
}

