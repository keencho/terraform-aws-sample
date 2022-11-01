provider "aws" {
  region = "ap-northeast-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = {
      Project = "${var.default_name}-project"
    }
  }
}