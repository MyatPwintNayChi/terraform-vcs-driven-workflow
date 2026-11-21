data "terraform_remote_state" "backend_network" {
  backend = "remote"

  config = {
    organization = "hello-cloud"
    workspaces = {
      name = "backend-network"
    }
  }
}

data "terraform_remote_state" "backend_security_groups" {
  backend = "remote"

  config = {
    organization = "hello-cloud"
    workspaces = {
      name = "backend-security-groups"
    }
  }
}
