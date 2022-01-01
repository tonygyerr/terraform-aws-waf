module "waf" {
  source = "git::https://github.com/tonygyerr/terraform-aws-waf.git"

  app_name              = var.app_name
  alb_arn               = data.aws_lb.this.arn
  associate_alb         = true
  aws_region            = var.aws_region
  dead_letter_arn       = var.dead_letter_arn
  environment           = var.environment
  excluded_rules        = var.excluded_rules
  profile               = var.profile
  blocked_path_prefixes = ["/admin", "/password"]
  allowed_hosts         = var.allowed_hosts
  rate_based_rules      = [module.waf.waf_rate_based_rule]
  scope                 = var.scope
  web_acl_name          = "${var.app_name}Wacl"
  web_acl_metric_name   = "${var.app_name}WaclMetric"
}