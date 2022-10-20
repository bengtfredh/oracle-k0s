terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
  }
  backend "s3" {
    endpoint                    = "https://frwbniwpnquy.compat.objectstorage.eu-frankfurt-1.oraclecloud.com"
    bucket                      = "tfstate"
    key                         = "oracle-k0s.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
