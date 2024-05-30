##  Helm charts control ##
variable "monitoring_helm_enabled" {
  description = "Create Prometheus/Grafana helm chart"
  type        = bool
  default     = true
}

variable "py_logging_helm_enabled" {
  description = "Create python logging app helm"
  type        = bool
  default     = true
}

variable "py_logging_gh_token" {
  description = "Token for gh packages image for demo app"
  type        = string
  default     = ""
}

variable "echo_nginx_server_helm_enabled" {
  description = "Create Echo nginx server helm chart"
  type        = bool
  default     = true
}

variable "loki_helm_enabled" {
  description = "Create loki helm chart"
  type        = bool
  default     = true
}
