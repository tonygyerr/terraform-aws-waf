output "waf_acl_id" {
  description = "WAF ACL ID generated by the module"
  value       = aws_wafregional_web_acl.wafacl.id
}
