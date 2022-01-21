resource "aws_cognito_user_pool" "emr" {
  name = local.name

  mfa_configuration = "OPTIONAL"

  software_token_mfa_configuration {
    enabled = true
  }

  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true

    invite_message_template {
      email_message = var.email_template
      email_subject = "Your temporary password (please reset - valid only for 24 hours)"
      sms_message   = "Your username is {username} and temporary password is {####}"
    }
  }

  device_configuration {
    challenge_required_on_new_device      = false
    device_only_remembered_on_user_prompt = true
  }

  email_configuration {
    email_sending_account  = "DEVELOPER"
    source_arn             = "arn:aws:ses:eu-west-1:${var.mgmt_account}:identity/${var.ses_domain}"
    from_email_address     = "noreply@${var.ses_domain}"
    reply_to_email_address = "noreply@${var.ses_domain}"
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
    default_email_option = "CONFIRM_WITH_LINK"
  }

  lambda_config {
    create_auth_challenge          = var.auth_lambdas.create_auth_challenge
    define_auth_challenge          = var.auth_lambdas.define_auth_challenge
    verify_auth_challenge_response = var.auth_lambdas.verify_auth_challenge_response
    pre_authentication             = var.auth_lambdas.pre_authentication
    post_authentication            = var.auth_lambdas.post_authentication
    pre_token_generation           = var.auth_lambdas.pre_token_generation
  }

  tags = merge(var.common_tags, { Name = local.name, Persistance = "True" })

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [schema]
  }
}

data "template_file" "metadata_adfs" {
  template = file("${path.module}/FederationMetadata-20200402.xml.tpl")
}

resource "aws_cognito_identity_provider" "adfs_dwp" {
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
