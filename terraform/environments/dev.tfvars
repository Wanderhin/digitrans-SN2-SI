# Variables pour l'environnement de développement

environment = "dev"
project_name = "digitrans-cm"
aws_region = "af-south-1"

# Network
vpc_cidr = "10.1.0.0/16"

# Security - IP ranges autorisées (plus permissif en dev)
allowed_ip_ranges = [
  "0.0.0.0/0"  # Accès depuis n'importe où en dev
]

on_premise_ip_ranges = [
  "196.168.1.0/24"
]

# Database (instances plus petites en dev)
db_instance_class = "db.t3.medium"

# GitHub
github_repo = "CAMTECH-SOLUTIONS/digitrans-cm"

# ACM Certificate
acm_certificate_arn = "arn:aws:acm:af-south-1:ACCOUNT_ID:certificate/CERTIFICATE_ID"

# Monitoring
alert_email = "dev-team@agrocam.cm"

# Secrets (à charger depuis AWS Secrets Manager en production)
# db_username et db_password doivent être définis via variables d'environnement ou Secrets Manager
# Pour dev seulement (NE JAMAIS faire en prod) :
# db_username = "postgres"
# db_password = "devpassword123!"
