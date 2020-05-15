resource aws_cognito_user_pool emr {
  name = local.name

  mfa_configuration = "OPTIONAL"

  software_token_mfa_configuration {
    enabled = true
  }

  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  device_configuration {
    challenge_required_on_new_device      = false
    device_only_remembered_on_user_prompt = true
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  password_policy {
    minimum_length                   = 18
    require_lowercase                = false
    require_numbers                  = false
    require_symbols                  = false
    require_uppercase                = false
    temporary_password_validity_days = 1
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
  tags = merge(var.common_tags, { Name = local.name })
}

data template_file metadata {
  template = file("${path.module}/saml-metadata.xml.tpl")
}

resource aws_cognito_identity_provider adfs {
  user_pool_id  = aws_cognito_user_pool.emr.id
  provider_name = "ADFS"
  provider_type = "SAML"

  provider_details = {
    MetadataFile          = data.template_file.metadata.rendered
    IDPSignout            = false
    SLORedirectBindingURI = "https://dataworks.com/adfs/ls/"
    SSORedirectBindingURI = "https://dataworks.com/adfs/ls/"
  }

  attribute_mapping = {
    email    = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
    profile  = "http://schemas.xmlsoap.org/claims/UPN"
    zoneinfo = "http://schemas.xmlsoap.org/claims/Group"
  }
}

data template_file metadata_adfs {
  template = file("${path.module}/FederationMetadata-20200402.xml.tpl")
}

resource aws_cognito_identity_provider adfs_dwp {
  user_pool_id  = aws_cognito_user_pool.emr.id
  provider_name = "DWP"
  provider_type = "SAML"

  provider_details = {
    MetadataFile          = data.template_file.metadata_adfs.rendered
    IDPSignout            = false
    SLORedirectBindingURI = "https://sts.dwp.gov.uk/adfs/ls/"
    SSORedirectBindingURI = "https://sts.dwp.gov.uk/adfs/ls/"
  }

  attribute_mapping = {
    email              = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
    preferred_username = "sAMAccountName"
  }
}
