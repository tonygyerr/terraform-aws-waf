resource "aws_wafregional_byte_match_set" "allowed_hosts" {
  name = format("%s-allowed-hosts", var.web_acl_name)

  dynamic "byte_match_tuples" {
    for_each = var.allowed_hosts
    content {

      # Even though the AWS Console web UI suggests a capitalized "host" data,
      # the data should be lower case as the AWS API will silently lowercase anyway.
      field_to_match {
        type = "HEADER"
        data = "host"
      }

      target_string = byte_match_tuples.value

      # See ByteMatchTuple for possible variable options.
      # See https://docs.aws.amazon.com/waf/latest/APIReference/API_ByteMatchTuple.html#WAF-Type-ByteMatchTuple-PositionalConstraint
      positional_constraint = "EXACTLY"

      # Use COMPRESS_WHITE_SPACE to prevent sneaking around regex filter with
      # extra or non-standard whitespace
      # See https://docs.aws.amazon.com/sdk-for-go/api/service/waf/#RegexMatchTuple
      text_transformation = "COMPRESS_WHITE_SPACE"
    }
  }
}

resource "aws_wafregional_byte_match_set" "blocked_path_prefixes" {
  name = format("%s-blocked-path-prefixes", var.web_acl_name)

  dynamic "byte_match_tuples" {
    for_each = var.blocked_path_prefixes
    content {
      field_to_match {
        type = "URI"
      }

      target_string = byte_match_tuples.value

      # See ByteMatchTuple for possible variable options.
      # See https://docs.aws.amazon.com/waf/latest/APIReference/API_ByteMatchTuple.html#WAF-Type-ByteMatchTuple-PositionalConstraint
      positional_constraint = "STARTS_WITH"

      # Use COMPRESS_WHITE_SPACE to prevent sneaking around regex filter with
      # extra or non-standard whitespace
      # See https://docs.aws.amazon.com/sdk-for-go/api/service/waf/#RegexMatchTuple
      text_transformation = "COMPRESS_WHITE_SPACE"
    }
  }
}