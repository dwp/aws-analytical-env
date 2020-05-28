resource "aws_wafregional_geo_match_set" "gb" {
  name = "geo_match_set"

  geo_match_constraint {
    type  = "Country"
    value = "GB"
  }
}
