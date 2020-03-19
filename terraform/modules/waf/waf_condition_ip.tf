## OWASP Top 10 July 2017 A5
## Privileged Module Access Restrictions
## Restrict access to the admin interface to known source IPs only
## Matches the URI prefix, when the remote IP isn't in the whitelist
resource "aws_wafregional_ipset" "admin_remote_ipset" {
  name = "match-admin-remote-ip"

  dynamic "ip_set_descriptor" {
    for_each = var.whitelist_cidr_blocks

    content {
      value = ip_set_descriptor.value
      type  = "IPV4"
    }
  }
}
