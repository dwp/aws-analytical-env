## 2.
## OWASP Top 10 July 2017 A2
## Blacklist bad/hijacked JWT tokens or session IDs
## Matches the specific values in the cookie or Authorization header
## for JWT it is sufficient to check the signature
resource "aws_wafregional_byte_match_set" "match_auth_tokens" {
  name = "match-auth-tokens"

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = ".TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "HEADER"
      data = "authorization"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "example-session-id"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "HEADER"
      data = "cookie"
    }
  }
}

## 4.
## OWASP Top 10 July 2017 A4
## Path Traversal, LFI, RFI
## Matches request patterns designed to traverse filesystem paths, and include
## local or remote files
resource "aws_wafregional_byte_match_set" "match_rfi_lfi_traversal" {
  name = "match-rfi-lfi-traversal"

  byte_match_tuples {
    text_transformation   = "HTML_ENTITY_DECODE"
    target_string         = "://"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "HTML_ENTITY_DECODE"
    target_string         = "../"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "://"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "../"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "QUERY_STRING"
    }
  }

  byte_match_tuples {
    text_transformation   = "HTML_ENTITY_DECODE"
    target_string         = "://"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "HTML_ENTITY_DECODE"
    target_string         = "../"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "URI"
    }
  }


  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "://"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "../"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "URI"
    }
  }
}

## OWASP Top 10 July 2017 A5
## Privileged Module Access Restrictions
## Restrict access to the admin interface to known source IPs only
## Matches the URI prefix, when the remote IP isn't in the whitelist
resource "aws_wafregional_byte_match_set" "match_admin_url" {
  name = "match-admin-url"

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = "/metrics"
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".ops."
    positional_constraint = "CONTAINS"

    field_to_match {
      type = "HEADER"
      data = "host"
    }
  }
}

## 8.
## OWASP Top 10 July 2017 A8
## CSRF token enforcement example
## Enforce the presence of CSRF token in request header
resource "aws_wafregional_byte_match_set" "match_csrf_method" {
  name = "match-csrf-method"

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = "post"
    positional_constraint = "EXACTLY"

    field_to_match {
      type = "METHOD"
    }
  }
}

## 9.
## OWASP Top 10 July 2017 A9
## Server-side includes & libraries in webroot
## Matches request patterns for webroot objects that shouldn't be directly accessible
resource "aws_wafregional_byte_match_set" "match_ssi" {
  name = "match-ssi"

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".cfg"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".backup"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".ini"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".conf"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".log"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".bak"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "LOWERCASE"
    target_string         = ".config"
    positional_constraint = "ENDS_WITH"

    field_to_match {
      type = "URI"
    }
  }

  byte_match_tuples {
    text_transformation   = "URL_DECODE"
    target_string         = "/includes"
    positional_constraint = "STARTS_WITH"

    field_to_match {
      type = "URI"
    }
  }
}
