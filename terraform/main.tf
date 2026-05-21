# Infrastructure Hybride AWS pour DIGITRANS-CM
# Région: af-south-1 (Cape Town) - Souveraineté des données africaines

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "digitrans-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "af-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "DIGITRANS-CM"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Client      = "AGROCAM-SA"
      CostCenter  = "IT-Infrastructure"
    }
  }
}

# Variables
variable "aws_region" {
  description = "AWS Region - Cape Town pour souveraineté africaine"
  type        = string
  default     = "af-south-1"
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "digitrans-cm"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}



variable "allowed_ip_ranges" {
  description = "IP ranges autorisées (Cameroun)"
  type        = list(string)
  default     = ["41.202.0.0/16", "154.72.0.0/16"] # Plages IP Cameroun
}
