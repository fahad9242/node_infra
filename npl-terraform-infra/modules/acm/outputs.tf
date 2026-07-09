# The validated ARN — depending on this (not the raw cert) forces the HTTPS
# listener to wait until the cert is actually issued.
output "certificate_arn" {
  description = "ARN of the validated ACM certificate."
  value       = aws_acm_certificate_validation.this.certificate_arn
}
