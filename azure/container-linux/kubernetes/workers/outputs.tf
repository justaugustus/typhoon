output "ingress_dns_name" {
  value       = "${var.name}-ing.${var.dns_zone}"
  description = "DNS name of the Public IP for distributing traffic to Ingress controllers"
}
