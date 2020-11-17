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
        RoleMappings = concat([
          for group, policy_suffixes in var.security_configuration_groups : [
            {
              Role           = aws_iam_role.emrfs_iam[group].arn
              IdentifierType = "Group"
              Identifiers    = [group]
            }
          ]
          ], [
          for user, role in var.security_configuration_user_roles : [
            {
              Role           = role
              IdentifierType = "User"
              Identifiers    = [user]
            }
          ]
        ])
      }
    }
  }
}

resource "aws_emr_security_configuration" "emrfs_em" {
  name          = md5(jsonencode(local.emrfs_em))
  configuration = jsonencode(local.emrfs_em)
}
