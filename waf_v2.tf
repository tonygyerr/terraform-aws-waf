# Source: https://github.com/awslabs/aws-waf-security-automations/blob/master/deployment/aws-waf-security-automations-webacl.template
resource "aws_wafv2_web_acl" "main" {
  name  = "${local.name}wafACL"
  scope = var.scope

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = "${local.name}wafACL"
  }

  default_action {
    allow {}
    // find way to connect ot var.defaultAction
  }

  rule {
    name     = "${local.name}wafAWSManagedRulesCommonRuleSet"
    priority = 0
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name}wafAWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        // Rules: https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-list.html
        dynamic "excluded_rule" {
          for_each = var.excluded_rules
          content {
            name = excluded_rule.value
          }
        }
      }
    }
  }

  dynamic "rule" {
    for_each = var.whitelistActivated ? [
    true] : []
    content {
      name     = "${local.name}wafWhitelistRule"
      priority = 1
      action {
        allow {}
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.name}wafWhitelistRule"
        sampled_requests_enabled   = true
      }
      statement {
        or_statement {
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.WhitelistSetV4.arn
            }
          }
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.WhitelistSetV6.arn
            }
          }
        }
      }
    }
  }

  dynamic "rule" {
    for_each = var.blacklistProtectionActivated || var.httpFloodProtectionLogParserActivated || var.scannersProbesProtectionActivated || var.reputationListsProtectionActivated || var.badBotProtectionActivated ? [
    true] : []
    content {
      name     = "${local.name}wafBlacklistRule"
      priority = 2
      action {
        block {}
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.name}wafBlacklistRule"
        sampled_requests_enabled   = true
      }
      statement {
        or_statement {
          dynamic "statement" {
            for_each = var.blacklistProtectionActivated ? [
            true] : []
            content {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.BlacklistSetIPV4.arn
              }
            }
          }
          dynamic "statement" {
            for_each = var.blacklistProtectionActivated ? [
            true] : []
            content {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.BlacklistSetIPV6.arn
              }
            }
          }

          dynamic "statement" {
            for_each = var.httpFloodProtectionLogParserActivated ? [
            true] : []
            content {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.HTTPFloodSetIPV4.arn
              }
            }
          }
          dynamic "statement" {
            for_each = var.scannersProbesProtectionActivated ? [
            true] : []
            content {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.HTTPFloodSetIPV6.arn
              }
            }
          }

          dynamic "statement" {
            for_each = var.scannersProbesProtectionActivated ? [
            true] : []
            content {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.ScannersProbesSetIPV4.arn
              }
            }
          }
          dynamic "statement" {
            for_each = var.httpFloodProtectionLogParserActivated ? [
            true] : []
            content {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.ScannersProbesSetIPV6.arn
              }
            }
          }

          dynamic "statement" {
            for_each = var.reputationListsProtectionActivated ? [
            true] : []
            content {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.IPReputationListsSetIPV4.arn
              }
            }
          }
          dynamic "statement" {
            for_each = var.reputationListsProtectionActivated ? [
            true] : []
            content {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.IPReputationListsSetIPV6.arn
              }
            }
          }

          dynamic "statement" {
            for_each = var.badBotProtectionActivated ? [
            true] : []
            content {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.IPBadBotSetIPV4.arn
              }
            }
          }
          dynamic "statement" {
            for_each = var.badBotProtectionActivated ? [
            true] : []
            content {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.IPBadBotSetIPV6.arn
              }
            }
          }
        }
      }
    }
  }

  /*dynamic "rule" {
    for_each = var.blacklistProtectionActivated ? [
      true]: []
    content {
      name = "${local.name}wafBlacklistRule"
      priority = 2
      action {
        block {}
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name = "${local.name}wafBlacklistRule"
        sampled_requests_enabled = true
      }
      statement {
        or_statement {
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.BlacklistSetIPV4.arn
            }
          }
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.BlacklistSetIPV6.arn
            }
          }
        }
      }
    }
  }*/

  /*dynamic "rule" {
    for_each = var.httpFloodProtectionLogParserActivated ? [
      true]: []
    content {
      name = "${local.name}wafHttpFloodRegularRule"
      priority = 3
      action {
        block {}
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name = "${local.name}wafHttpFloodRegularRule"
        sampled_requests_enabled = true
      }
      statement {
        or_statement {
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.HTTPFloodSetIPV4.arn
            }
          }
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.HTTPFloodSetIPV6.arn
            }
          }
        }
      }
    }
  }*/

  rule {
    name     = "${local.name}wafHttpFloodRateBasedRule"
    priority = 4
    action {
      block {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name}wafHttpFloodRateBasedRule"
      sampled_requests_enabled   = true
    }
    statement {
      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = var.requestThreshold
      }
    }
  }


  /*dynamic "rule" {
    for_each = var.scannersProbesProtectionActivated ? [
      true]: []
    content {
      name = "${local.name}wafScannersAndProbesRule"
      priority = 5
      action {
        block {}
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name = "${local.name}wafScannersAndProbesRule"
        sampled_requests_enabled = true
      }
      statement {
        or_statement {
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.ScannersProbesSetIPV4.arn
            }
          }
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.ScannersProbesSetIPV6.arn
            }
          }
        }
      }
    }
  }*/

  /*dynamic "rule" {
    for_each = var.reputationListsProtectionActivated ? [
      true]: []
    content {
      name = "${local.name}wafIPReputationListsRule"
      priority = 6
      action {
        block {}
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name = "${local.name}wafIPReputationListsRule"
        sampled_requests_enabled = true
      }
      statement {
        or_statement {
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.IPReputationListsSetIPV4.arn
            }
          }
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.IPReputationListsSetIPV6.arn
            }
          }
        }
      }
    }
  }*/

  /*dynamic "rule" {
    for_each = var.badBotProtectionActivated ? [
      true]: []
    content {
      name = "${local.name}wafBadBotRule"
      priority = 7
      action {
        block {}
      }
      visibility_config {
        sampled_requests_enabled = true
        cloudwatch_metrics_enabled = true
        metric_name = "${local.name}wafBadBotRule"
      }
      statement {
        or_statement {
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.IPBadBotSetIPV4.arn
            }
          }
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.IPBadBotSetIPV6.arn
            }
          }
        }
      }
    }
  }*/

  rule {
    name     = "${local.name}wafSqlInjectionRule"
    priority = 20
    action {
      block {}
    }
    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name}wafSqlInjectionRule"
    }
    statement {
      or_statement {
        statement {
          sqli_match_statement {
            field_to_match {
              query_string {}
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }
        statement {
          sqli_match_statement {
            field_to_match {
              body {}
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }
        statement {
          sqli_match_statement {
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }
        statement {
          sqli_match_statement {
            field_to_match {
              single_header {
                name = "authorization"
              }
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }
        statement {
          sqli_match_statement {
            field_to_match {
              single_header {
                name = "cookie"
              }
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }
      }
    }
  }
  rule {
    name     = "${local.name}wafXssRule"
    priority = 30
    action {
      block {}
    }
    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name}wafXssRule"
    }
    statement {
      or_statement {
        statement {
          xss_match_statement {
            field_to_match {
              query_string {}
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }
        statement {
          xss_match_statement {
            field_to_match {
              body {}
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }
        statement {
          xss_match_statement {
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }
        statement {
          xss_match_statement {
            field_to_match {
              single_header {
                name = "cookie"
              }
            }
            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "HTML_ENTITY_DECODE"
            }
          }
        }
      }
    }
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = [
  aws_kinesis_firehose_delivery_stream.main.arn]
  resource_arn = aws_wafv2_web_acl.main.arn

  redacted_fields {
    single_header {
      name = "authorizer"
    }
  }
  redacted_fields {
    single_header {
      name = "cookie"
    }
  }
  redacted_fields {
    single_header {
      name = "user-agent"
    }
  }
}

resource "aws_wafv2_web_acl_association" "main" {
  count        = var.associate_alb ? 1 : 0
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}