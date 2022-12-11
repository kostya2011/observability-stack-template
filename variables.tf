variable "monitoring_helm_enabled" {
  description = "Create Prometheus/Grafana helm chart"
  type        = bool
  default     = false
}

variable "py_logging_helm_enabled" {
  description = "Create python logging app helm"
  type        = bool
  default     = false
}

variable "echo_nginx_server_helm_enabled" {
  description = "Create Echo nginx server helm chart"
  type        = bool
  default     = false
}
