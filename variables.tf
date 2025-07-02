############################
# Variables de entrada
############################

# Región de despliegue (elige una de menor coste)
variable "location" {
  description = "Región Azure compatible con precios bajos"
  default     = "eastus2"
}

# Prefijo para nombres (3-11 caracteres, minúsculas/números)
variable "resource_prefix" {
  description = "Prefijo para nombrar recursos"
  default     = "webdemo"
}

# Etiquetas comunes — FinOps + Gobernanza
variable "tags_common" {
  description = "Etiquetas FinOps & Governance"
  type        = map(string)
  default = {
    environment  = "lab"                        # Entorno (prod/dev/lab)
    owner        = "tu.email@dominio.com"        # Persona o equipo responsable
    project      = "storage-static-website"      # Identificador del proyecto
    cost_center  = "demo"                        # Centro de coste
    delete_after = "2025-07-01T23:59:00Z"        # Auto-limpieza programática
  }
}