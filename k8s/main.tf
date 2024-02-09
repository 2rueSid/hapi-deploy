locals {
  namespace = "hapi-fhir"

  secrets_name = "hapi-db-creds"
  dialect      = "ca.uhn.fhir.jpa.model.dialect.HapiFhirPostgres94Dialect"
}

resource "kubernetes_secret" "hapi-db-creds" {
  metadata {
    name      = local.secrets_name
    namespace = local.namespace
  }

  data = {
    url      = "jdbc:${var.db_engine}://${var.db_host}:${var.db_port}/${var.db_name}"
    username = base64encode(var.db_username)
    password = base64encode(var.db_password)
  }
}

resource "kubernetes_config_map" "hapi_config" {
  metadata {
    name      = "hapi-config"
    namespace = local.namespace
  }

  data = {
    "application.yaml" = yamlencode({
      spring = {
        datasource = {
          driverClassName = "org.${var.db_engine}.Driver"
        }
        jpa = {
          properties = {
            hibernate = {
              dialect = local.dialect
            }
          }
        }
      }
    })
  }
}
resource "kubernetes_deployment" "fhir" {
  metadata {
    name      = "fhir"
    namespace = local.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "fhir"
      }
    }

    template {
      metadata {
        labels = {
          app = "fhir"
        }
      }

      spec {
        container {
          name  = "fhir"
          image = "hapiproject/hapi:latest"
          port {
            container_port = 8080
          }

          env {
            name = "SPRING_DATASOURCE_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.hapi-db-creds.metadata[0].name
                key  = "url"
              }
            }
          }
          env {
            name = "SPRING_DATASOURCE_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.hapi-db-creds.metadata[0].name
                key  = "username"
              }
            }
          }
          env {
            name = "SPRING_DATASOURCE_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.hapi-db-creds.metadata[0].name
                key  = "password"
              }
            }
          }

          volume_mount {
            mount_path = "/app/config/application.yaml"
            name       = "hapi-config"
            sub_path   = "application.yaml"
          }
        }

        volume {
          name = "hapi-config"

          config_map {
            name = kubernetes_config_map.hapi_config.metadata[0].name
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "fhir_service" {
  metadata {
    name      = "fhir-service"
    namespace = local.namespace
  }

  spec {
    selector = {
      app = "fhir"
    }
    type = "NodePort"
    port {
      port        = 8080
      target_port = 8080
      node_port   = 30080
    }
  }
}
