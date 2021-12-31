resource "aws_wafregional_web_acl" "wafacl" {
  name        = var.web_acl_name
  metric_name = var.web_acl_metric_name

  default_action {
    type = "ALLOW"
  }

  dynamic "rule" {
    for_each = aws_wafregional_rule.ips.*.id
    content {
      type     = "REGULAR"
      rule_id  = rule.value
      priority = 1 + rule.key

      action {
        type = "BLOCK"
      }
    }
  }

  rule {
    type     = "REGULAR"
    rule_id  = aws_wafregional_rule.allowed_hosts.id
    priority = 1 + length(aws_wafregional_rule.ips.*.id)

    action {
      type = "BLOCK"
    }
  }

  rule {
    type     = "REGULAR"
    rule_id  = aws_wafregional_rule.blocked_path_prefixes.id
    priority = 1 + length(aws_wafregional_rule.ips.*.id) + 1

    action {
      type = "BLOCK"
    }
  }

  dynamic "rule" {
    for_each = var.rate_based_rules
    content {
      type     = "RATE_BASED"
      rule_id  = rule.value
      priority = 1 + length(aws_wafregional_rule.ips.*.id) + 1 + 1 + rule.key

      action {
        type = "BLOCK"
      }
    }
  }

  dynamic "rule" {
    for_each = length(var.wafregional_rule_f5_id) > 0 ? [var.wafregional_rule_f5_id] : []
    content {
      type     = "GROUP"
      rule_id  = rule.value
      priority = 1 + length(aws_wafregional_rule.ips.*.id) + 1 + 1 + length(var.rate_based_rules) + rule.key

      override_action {
        type = "NONE"
      }
    }
  }

  dynamic "rule" {
    for_each = var.rules
    content {
      type     = "REGULAR"
      rule_id  = rule.value
      priority = 1 + length(aws_wafregional_rule.ips.*.id) + 1 + 1 + length(var.rate_based_rules) + (length(var.wafregional_rule_f5_id) > 0 ? 1 : 0) + rule.key

      action {
        type = "BLOCK"
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_wafregional_web_acl_association" "main" {
  count        = var.associate_alb ? 1 : 0
  resource_arn = var.alb_arn
  web_acl_id   = aws_wafregional_web_acl.wafacl.id
}