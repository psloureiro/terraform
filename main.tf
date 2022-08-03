terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Configure resource Kubernetes cluster
resource "digitalocean_kubernetes_cluster" "k8s_iniciativa_devops" {
  name   = var.k8s_name
  region = var.do_region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.23.9-do.0"

  node_pool {
    name       = "default-pool"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

# Configure a additional node pool
resource "digitalocean_kubernetes_node_pool" "node_premium" {
  cluster_id = digitalocean_kubernetes_cluster.k8s_iniciativa_devops.id

  name       = "premium-pool"
  size       = "s-2vcpu-2gb"
  node_count = 2
}

# Configure resource - kube config
resource "local_file" "kube_config" {
    content  = digitalocean_kubernetes_cluster.k8s_iniciativa_devops.kube_config.0.raw_config
    filename = "kube_config.yaml"
}

# Output definitions
output "kube_endpoint" {
   description = "The base URL of the API server on the Kubernetes master node" 
   value = digitalocean_kubernetes_cluster.k8s_iniciativa_devops.endpoint
} 

# Variables definition
variable "do_token" {
  type        = string
  description = "Digital Ocean access token"
  default     = ""
}

variable "k8s_name" {
  type        = string
  description = "Kubernetes cluster name"
  default     = "k8s_cluster"
}

variable "do_region" {
  type        = string
  description = "DigitalOcean region"
  default     = "nyc1"
}
