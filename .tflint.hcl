#----------------------------------------------------------------------------
# .tflint.hcl
# use the following command to install on a Mac:
# brew install tflint
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# plugins
#----------------------------------------------------------------------------

plugin "terraform" {
  enabled = true
  preset  = "all"
}

plugin "google" {
  enabled = true
  version = "0.29.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}
