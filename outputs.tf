############################
# Outputs
############################

# URL pública HTTPS del sitio estático
output "website_url" {
  description = "URL HTTPS de tu sitio"
  value       = azurerm_storage_account.sa.primary_web_endpoint
}

# Nombre del Resource Group (para scripts de limpieza)
output "resource_group" {
  description = "Resource Group que contiene todos los recursos"
  value       = azurerm_resource_group.rg.name
}