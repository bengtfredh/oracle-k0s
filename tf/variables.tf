variable "client_certificate" {
  type = string
}
variable "client_key" {
  type = string
}
variable "cluster_ca_certificate" {
  type = string
}
variable "kubernetes_host" {
  type = string
}
variable "traefik_hub_token" {
  type = string
}

variable "traefik_dashboard_auth" {
  type = string
}

variable "metallb_version" {
  type = string
}
variable "traefik_version" {
  type = string
}
