# Estado de este entorno en S3. El resto llega con -backend-config (ver README)
terraform {
  backend "s3" {
    key = "pro/terraform.tfstate"
  }
}
