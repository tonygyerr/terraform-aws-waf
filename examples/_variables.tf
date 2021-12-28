variable "aws_region" {
  description = "ec2 region for the vpc"
  type        = string
  default     = ""
}

variable "profile" {
  description = "The name of the aws profile"
  type        = string
  default     = ""
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer (ALB) to be associated with the Web Application Firewall (WAF) Access Control List (ACL)."
  type        = string
  default     = ""
}

variable "web_acl_name" {
  description = "Name of the Web ACL"
  type        = string
  default     = ""
}

variable "web_acl_metric_name" {
  description = "Metric name of the Web ACL"
  type        = string
  default     = ""
}

variable "waf_acl_name" {
  type    = string
  default = ""
}

variable "private_subnets" {
  description = "list of private subnets for application and database layer"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "list of public subnets for alb"
  type        = list(string)
  default     = []
}

variable "app_name" {
  type        = string
  description = "Application Name"
  default     = ""
}

variable "vpc_name" {
  type    = string
  default = ""
}

variable "deploy_env_map" {
  type = map(any)
  default = {
    dev  = "develop"
    test = "test"
    prod = "prod"
  }
}

variable "environment" {
  type    = string
  default = ""
}