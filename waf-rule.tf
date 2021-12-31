resource "aws_wafregional_rule" "ips" {
  count = length(var.ip_sets)

  name        = format("%s-ips-%d", var.web_acl_name, count.index)
  metric_name = format("%sIPs%d", var.web_acl_metric_name, count.index)

  predicate {
    data_id = var.ip_sets[count.index]
    negated = false
    type    = "IPMatch"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_wafregional_rule" "blocked_path_prefixes" {
  name        = format("%s-blocked-path-prefixes", var.web_acl_name)
  metric_name = format("%sBlockedPathPrefixes", var.web_acl_metric_name)

  predicate {
    type    = "ByteMatch"
    data_id = aws_wafregional_byte_match_set.blocked_path_prefixes.id
    negated = false
  }
}

resource "aws_wafregional_rule" "allowed_hosts" {
  name        = format("%s-allowed-hosts", var.web_acl_name)
  metric_name = format("%sAllowedHosts", var.web_acl_metric_name)

  predicate {
    type    = "ByteMatch"
    data_id = aws_wafregional_byte_match_set.allowed_hosts.id
    negated = true
  }
}

resource "aws_wafregional_rate_based_rule" "ipratelimit" {
  name        = "${var.app_name}-global-ip-rate-limit"
  metric_name = "wafAppGlobalIpRateLimit"
  rate_key    = "IP"
  rate_limit  = 2000
}