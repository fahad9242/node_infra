variable "domain_name" {
  description = "Fully-qualified domain name the certificate is issued for."
  type        = string
}

variable "zone_id" {
  description = "Route53 hosted zone ID where DNS validation records are created."
  type        = string
}
