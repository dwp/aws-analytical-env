locals {
  emrfs_em = {
    EncryptionConfiguration = {
      EnableInTransitEncryption = false

      EnableAtRestEncryption = true
      AtRestEncryptionConfiguration = {
        S3EncryptionConfiguration = {
          EncryptionMode             = "CSE-Custom"
          S3Object                   = "s3://${var.artefact_bucket.id}/emr-encryption-materials-provider/encryption-materials-provider-all.jar"
          EncryptionKeyProviderClass = "uk.gov.dwp.dataworks.dks.encryptionmaterialsprovider.DKSEncryptionMaterialsProvider"
          Overrides = [
            {
              EncryptionMode = "SSE-KMS",
              BucketName     = var.jupyterhub_bucket.id,
              AwsKmsKey      = var.jupyterhub_bucket.cmk_arn
            }
          ]
        }
        LocalDiskEncryptionConfiguration = {
          EncryptionKeyProviderType = "AwsKms"
          AwsKmsKey                 = aws_kms_alias.emr_ebs.arn
          EnableEbsEncryption       = true
        }
      }
    }

    AuthorizationConfiguration = {
      EmrFsConfiguration = {
        RoleMappings = var.rbac_version == 2 ? flatten([
          for user, role in var.security_configuration_user_roles : [
            {
              Role           = role
              IdentifierType = "User"
              Identifiers    = [user]
            }
          ]]) : flatten([
          for group, policy_suffixes in var.security_configuration_groups : [
            {
              Role           = aws_iam_role.emrfs_iam[group].arn
              IdentifierType = "Group"
              Identifiers    = [group]
            }
          ]
        ])
      }
    }
  }

  batch_emrfs_em = {
    EncryptionConfiguration = {
      EnableInTransitEncryption = false

      EnableAtRestEncryption = true
      AtRestEncryptionConfiguration = {
        S3EncryptionConfiguration = {
          EncryptionMode             = "CSE-Custom"
          S3Object                   = "s3://${var.artefact_bucket.id}/emr-encryption-materials-provider/encryption-materials-provider-all.jar"
          EncryptionKeyProviderClass = "uk.gov.dwp.dataworks.dks.encryptionmaterialsprovider.DKSEncryptionMaterialsProvider"
        }
        LocalDiskEncryptionConfiguration = {
          EncryptionKeyProviderType = "AwsKms"
          AwsKmsKey                 = aws_kms_alias.emr_ebs.arn
          EnableEbsEncryption       = true
        }
      }
    }

    AuthorizationConfiguration = {
      EmrFsConfiguration = {
        RoleMappings = var.rbac_version == 2 ? flatten([
          for user, role in var.security_configuration_user_roles : [
            {
              Role           = role
              IdentifierType = "User"
              Identifiers    = [user]
            }
          ]]) : flatten([
          for group, policy_suffixes in var.security_configuration_groups : [
            {
              Role           = aws_iam_role.emrfs_iam[group].arn
              IdentifierType = "Group"
              Identifiers    = [group]
            }
          ]
        ])
      }
    }
  }
}

resource "aws_emr_security_configuration" "analytical_env_emrfs_em" {
  depends_on    = [aws_iam_policy.group_hive_data_access_policy]
  name          = "analytical_env_${md5(jsonencode(local.emrfs_em))}"
  configuration = jsonencode(local.emrfs_em)

  provisioner "local-exec" {
    when    = destroy
    command = "sleep 600"
  }
}

resource "aws_emr_security_configuration" "batch_emrfs_em" {
  depends_on    = [aws_iam_policy.group_hive_data_access_policy]
  name          = "batch_${md5(jsonencode(local.batch_emrfs_em))}"
  configuration = jsonencode(local.batch_emrfs_em)

  provisioner "local-exec" {
    when    = destroy
    command = "sleep 600"
  }
}
