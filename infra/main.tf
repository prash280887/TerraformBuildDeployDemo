# Check out https://app.terraform.io/app/ajg/registry/private/modules for some quick start modules from the IaC CoE Team
resource "time_rotating" "secret_rotation" {
  rotation_days = 90
  # expiration date set dynamically to be 90 days from deployment
}
