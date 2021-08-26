locals {

  munge_failure_alerts = {
    development = false
    qa          = false
    integration = false
    preprod     = true
    production  = true
  }

}
