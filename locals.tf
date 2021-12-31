locals {

  common_tags = {
    Manager   = "Terraform",
    Terraform = "v1.1.2",
    Context   = var.context
    Project   = var.project
  }
}
