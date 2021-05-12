resource "aws_wafregional_web_acl" "acl" {
  name        = local.name
  metric_name = local.name

  logging_configuration {
    log_destination = aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn
  }

  default_action {
    type = "BLOCK"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 1
    rule_id  = aws_wafregional_rule.non_gb.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 2
    rule_id  = aws_wafregional_rule.restrict_sizes.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 3
    rule_id  = aws_wafregional_rule.detect_bad_auth_tokens.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 4
    rule_id  = aws_wafregional_rule.mitigate_xss.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 5
    rule_id  = aws_wafregional_rule.detect_rfi_lfi_traversal.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "COUNT"
    }

    priority = 6
    rule_id  = aws_wafregional_rule.enforce_csrf.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 7
    rule_id  = aws_wafregional_rule.detect_ssi.id
    type     = "REGULAR"
  }

  rule {
    action {
      type = "ALLOW"
    }

    priority = 8
    rule_id  = aws_wafregional_rule.detect_admin_access.id
    type     = "REGULAR"
  }
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-acl" })
}
