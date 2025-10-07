terraform {
  backend "s3" {
    bucket         = "terraform-state-390402537634-3064"
    key            = "ecs-app/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
