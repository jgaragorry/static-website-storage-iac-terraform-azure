############################
# Terraform & Providers
############################
terraform {
  required_version = ">= 1.7"            # Garantiza compatibilidad con el HCL usado

  required_providers {
    azurerm = {                          # Provider principal: Azure RM
      source  = "hashicorp/azurerm"
      version = "~> 3.117"               # 3.117+ incluye Static Website estable
    }
    random = {                           # Genera sufijos aleatorios (nombres únicos)
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    time = {                             # Retraso de propagación (evita WebsiteDisabled)
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
  }
}

provider "azurerm" {
  features {}                            # Activa todas las features por defecto
}

########################################
# 1️⃣ Resource Group — Dominio de costes
########################################
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_prefix}-rg" # Ej. webdemo-rg
  location = var.location
  tags     = var.tags_common             # Etiquetas FinOps y governance
}

########################################
# 2️⃣ Storage Account — Almacenamiento económico
########################################
resource "random_string" "sa_suffix" {
  length  = 6                            # 6 chars: cumple requisitos de nombre (3-24)
  upper   = false
  special = false
}

resource "azurerm_storage_account" "sa" {
  name                     = "${var.resource_prefix}${random_string.sa_suffix.result}"
                                         # Ej. webdemoa1b2c3 (único globalmente)
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_kind             = "StorageV2" # Requisito para sitios estáticos
  account_tier             = "Standard"  # Más barato que Premium
  account_replication_type = "LRS"       # Copia única en una región (coste mínimo)
  min_tls_version          = "TLS1_2"    # Seguridad: fuerza TLS ≥ 1.2
  allow_nested_items_to_be_public = false# Bloquea blobs anónimos (seguridad)

  # 🔹 Habilita hosting estático integrado
  static_website {
    index_document     = "index.html"
    error_404_document = "index.html"
  }

  tags = merge(var.tags_common, { workload = "static-website" })
}

########################################
# 3️⃣ Espera propagación — evita WebsiteDisabled
########################################
resource "time_sleep" "wait_propagation" {
  depends_on      = [azurerm_storage_account.sa]
  create_duration = "30s"                # 30 s: margen fiable para contenedor $web
}

########################################
# 4️⃣ Carga del HTML — Contenido inicial
########################################
resource "azurerm_storage_blob" "index_html" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = "$web"        # Contenedor especial generado por Azure
  type                   = "Block"
  content_type           = "text/html"

  # HTML embebido → sitio listo sin archivos externos
  source_content = <<HTML
<!DOCTYPE html>
<html lang="en">
  <head><meta charset="utf-8"><title>¡Hola Azure Static Website!</title></head>
  <body style="font-family:sans-serif;text-align:center;margin-top:3rem;">
    <h1>🎉 Sitio estático en Azure Storage</h1>
    <p>Desplegado con <strong>Terraform</strong> – FinOps &amp; Security Ready.</p>
  </body>
</html>
HTML

  depends_on = [time_sleep.wait_propagation] # Sube solo tras la espera
}