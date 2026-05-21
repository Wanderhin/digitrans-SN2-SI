# Variables communes pour tous les environnements

# Network
vpc_cidr = "10.0.0.0/16"

# Security
allowed_ip_ranges = [
  "41.202.0.0/16",    # Cameroun Telecom
  "154.72.0.0/16",    # Orange Cameroun
  "196.168.1.0/24"    # AGROCAM On-Premise
]

on_premise_ip_ranges = [
  "196.168.1.0/24"
]

# Database
db_instance_class = "db.t3.large"

# GitHub
github_repo = "CAMTECH-SOLUTIONS/digitrans-cm"

# ACM Certificate
acm_certificate_arn = "arn:aws:acm:af-south-1:ACCOUNT_ID:certificate/CERTIFICATE_ID"

# Monitoring
alert_email = "devops@agrocam.cm"

# Secrets (à charger depuis AWS Secrets Manager)
# db_username et db_password doivent être définis via variables d'environnement ou Secrets Manager
