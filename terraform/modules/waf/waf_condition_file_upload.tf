## Match POST/PUT requests
resource "aws_wafregional_byte_match_set" "match_post_put" {
  name = "match-post-put"

  byte_match_tuples {
    field_to_match {
      type = "METHOD"
    }

    positional_constraint = "EXACTLY"
    target_string         = "POST"

    text_transformation = "NONE"
  }

  byte_match_tuples {
    field_to_match {
      type = "METHOD"
    }

    positional_constraint = "EXACTLY"
    target_string         = "PUT"

    text_transformation = "NONE"
  }
}


## Match file paths
resource "aws_wafregional_byte_match_set" "match_files_paths" {
  name = "match-file-paths"

  byte_match_tuples {
    field_to_match {
      type = "URI"
    }

    positional_constraint = "CONTAINS"
    target_string         = local.files_api_path

    text_transformation = "LOWERCASE"
  }

}
