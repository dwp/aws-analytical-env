resource "aws_wafregional_rule" "detect_admin_access" {
  name        = "detect-admin-access"
  metric_name = "detectadminaccess"

  predicate {
    data_id = aws_wafregional_ipset.admin_remote_ipset.id
    negated = false
    type    = "IPMatch"
  }
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-admin-waf-rule" })
}

resource "aws_wafregional_rule" "detect_bad_auth_tokens" {
  name        = "detect-bad-auth-tokens"
  metric_name = "detectbadauthtokens"

  predicate {
    data_id = aws_wafregional_byte_match_set.match_auth_tokens.id
    negated = false
    type    = "ByteMatch"
  }
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-bad-token-waf-rule" })
}

resource "aws_wafregional_rule" "detect_rfi_lfi_traversal" {
  name        = "detect-rfi-lfi-traversal"
  metric_name = "detectrfilfitraversal"

  predicate {
    data_id = aws_wafregional_byte_match_set.match_rfi_lfi_traversal.id
    negated = false
    type    = "ByteMatch"
  }
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-rfi-lfi-waf-rule" })
}

resource "aws_wafregional_rule" "detect_ssi" {
  name        = "detect-ssi"
  metric_name = "detectssi"

  predicate {
    data_id = aws_wafregional_byte_match_set.match_ssi.id
    negated = false
    type    = "ByteMatch"
  }
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-ssi-waf-rule" })
}

resource "aws_wafregional_rule" "enforce_csrf" {
  name        = "enforce-csrf"
  metric_name = "enforcecsrf"

  predicate {
    data_id = aws_wafregional_byte_match_set.match_csrf_method.id
    negated = false
    type    = "ByteMatch"
  }

  predicate {
    data_id = aws_wafregional_size_constraint_set.csrf_token_set.id
    negated = true
    type    = "SizeConstraint"
  }
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-csrf-waf-rule" })
}

resource "aws_wafregional_rule" "mitigate_sqli" {
  name        = "mitigate-sqli"
  metric_name = "mitigatesqli"

  # Don't do mitigate_sqli for Prometheus/Grafana is it blocks legitimate requests
  predicate {
    data_id = aws_wafregional_byte_match_set.match_admin_url.id
    negated = true
    type    = "ByteMatch"
  }

  predicate {
    data_id = aws_wafregional_sql_injection_match_set.sql_injection_match_set.id
    negated = false
    type    = "SqlInjectionMatch"
  }
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-sqli-waf-rule" })
}

resource "aws_wafregional_rule" "mitigate_xss" {
  name        = "mitigate-xss"
  metric_name = "mitigatexss"

  predicate {
    data_id = aws_wafregional_xss_match_set.xss_match_set.id
    negated = false
    type    = "XssMatch"
  }
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-xss-waf-rule" })
}

resource "aws_wafregional_rule" "restrict_sizes" {
  name        = "restrict-sizes"
  metric_name = "restrictsizes"

  predicate {
    data_id = aws_wafregional_ipset.admin_remote_ipset.id
    negated = true
    type    = "IPMatch"
  }

  predicate {
    data_id = aws_wafregional_size_constraint_set.size_restrictions.id
    negated = false
    type    = "SizeConstraint"
  }
  tags = merge(var.common_tags, { Name : "${var.name_prefix}-restrict-waf-rule" })
}

resource "aws_wafregional_rule" "non_gb" {
  name        = "non-gb"
  metric_name = "nongb"

  predicate {
    data_id = aws_wafregional_ipset.admin_remote_ipset.id
    negated = true
    type    = "IPMatch"
  }

  predicate {
    data_id = aws_wafregional_geo_match_set.gb.id
    negated = true
    type    = "GeoMatch"
  }

  tags = merge(var.common_tags, { Name : "${var.name_prefix}-non-gb-waf-rule" })
}

