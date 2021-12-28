resource "aws_wafregional_rate_based_rule" "ipratelimit" {
  name        = "${var.app_name}-global-ip-rate-limit"
  metric_name = "wafAppGlobalIpRateLimit"
  rate_key    = "IP"
  rate_limit  = 2000
}

module "waf" {
  source = "git::https://github.com/tonygyerr/terraform-aws-waf.git"

  alb_arn       = data.aws_lb.this.arn
  associate_alb = true

  blocked_path_prefixes = ["/admin", "/password"]
  allowed_hosts         = ["apples", "oranges"]

  rate_based_rules = [aws_wafregional_rate_based_rule.ipratelimit.id]

  web_acl_name        = "${var.app_name}-wacl"
  web_acl_metric_name = "${var.app_name}-wacl-metric"
}