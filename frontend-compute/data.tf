data "terraform_remote_state" "frontend_network" {
  backend = "remote"

  config = {
    organization = "hello-cloud"
    workspaces = {
      name = "frontend-network"
    }
  }
}

data "terraform_remote_state" "frontend_security_groups" {
  backend = "remote"

  config = {
    organization = "hello-cloud"
    workspaces = {
      name = "frontend-security-groups"
    }
  }
}
