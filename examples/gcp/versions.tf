terraform {
  required_version = "1.4.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "= 4.56.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "= 4.56.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 3.4.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "= 3.2.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.18.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.9.0"
    }
  }
}

locals {
  region           = "europe-west4"     // gke cluster region
  project_id       = "prj-d-gke-a21f"   // gcp project id of the gke cluster
  gke_cluster_name = "dev-europe-west4" // gke cluster name
}

data "google_client_config" "default" {}

data "google_container_cluster" "gke" {
  name     = local.gke_cluster_name
  location = local.region
  project  = local.project_id
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate)
    client_certificate     = base64decode(data.google_container_cluster.gke.master_auth[0].client_certificate)
    client_key             = base64decode(data.google_container_cluster.gke.master_auth[0].client_key)
  }
}
