resource "azurerm_container_app" "app" {
  name                         = var.name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = var.name
      image  = var.image
      cpu    = var.cpu
      memory = var.memory

      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "secret" {
        for_each = var.secrets
        content {
          name  = secret.key
          value = secret.value
        }
      }
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
  }

  dynamic "ingress" {
    for_each = var.is_ingress_public ? [1] : []
    content {
      external_enabled = true
      target_port     = 80
      traffic_weight {
        percentage      = 100
        latest_revision = true
      }
    }
  }

  dynamic "ingress" {
    for_each = var.is_ingress_public ? [] : [1]
    content {
      external_enabled = false
      target_port     = 80
      traffic_weight {
        percentage      = 100
        latest_revision = true
      }
    }
  }
}
