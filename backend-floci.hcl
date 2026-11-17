# Backend para Floci: terraform init -backend-config=../../backend-floci.hcl
# El bucket se indica aparte: -backend-config="bucket=<output bucket_estado>"
region                      = "eu-west-1"
use_lockfile                = true
access_key                  = "test"
secret_key                  = "test"
skip_credentials_validation = true
skip_requesting_account_id  = true
skip_metadata_api_check     = true
skip_region_validation      = true
skip_s3_checksum            = true
use_path_style              = true
endpoints = {
  s3 = "http://localhost:4566"
}
