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
        RoleMappings = [
          {
            Role           = aws_iam_role.emrfs_iam[0].arn
            IdentifierType = "Group"
            Identifiers    = [flatten([for i, x in var.security_configuration_groups: i])[0]]
          },
          {
            Role           = aws_iam_role.emrfs_iam[1].arn
            IdentifierType = "Group"
            Identifiers    = [flatten([for i, x in var.security_configuration_groups: i])[1]]
          }
        ]
      }
    }
  }
}

resource "aws_emr_security_configuration" "emrfs_em" {
  name          = md5(jsonencode(local.emrfs_em))
  configuration = jsonencode(local.emrfs_em)
}
