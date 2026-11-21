#############################################################
# 1. VPC Peering Connection (Frontend <-> Backend)
#############################################################

resource "aws_vpc_peering_connection" "fevpc_peering_bevpc" {
  vpc_id      = data.terraform_remote_state.frontend_network.outputs.vpc_id
  peer_vpc_id = data.terraform_remote_state.backend_network.outputs.vpc_id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "frontend-to-backend-peering"
  }
}

#############################################################
# 2. Route Table Entries (Private Subnet 02 & 03)
#############################################################

resource "aws_route" "fevpc_private_subnet02_to_bevpc_private_subnet02" {
  route_table_id            = data.terraform_remote_state.frontend_network.outputs.private_route_table_ids[1]
  destination_cidr_block    = data.terraform_remote_state.backend_network.outputs.private_subnet_cidrs[1]
  vpc_peering_connection_id = aws_vpc_peering_connection.fevpc_peering_bevpc.id
}

resource "aws_route" "bevpc_private_subnet02_to_fevpc_private_subnet02" {
  route_table_id            = data.terraform_remote_state.backend_network.outputs.private_route_table_ids[1]
  destination_cidr_block    = data.terraform_remote_state.frontend_network.outputs.private_subnet_cidrs[1]
  vpc_peering_connection_id = aws_vpc_peering_connection.fevpc_peering_bevpc.id
}

resource "aws_route" "fevpc_private_subnet03_to_bevpc_private_subnet03" {
  route_table_id            = data.terraform_remote_state.frontend_network.outputs.private_route_table_ids[2]
  destination_cidr_block    = data.terraform_remote_state.backend_network.outputs.private_subnet_cidrs[2]
  vpc_peering_connection_id = aws_vpc_peering_connection.fevpc_peering_bevpc.id
}

resource "aws_route" "bevpc_private_subnet03_to_fevpc_private_subnet03" {
  route_table_id            = data.terraform_remote_state.backend_network.outputs.private_route_table_ids[2]
  destination_cidr_block    = data.terraform_remote_state.frontend_network.outputs.private_subnet_cidrs[2]
  vpc_peering_connection_id = aws_vpc_peering_connection.fevpc_peering_bevpc.id
}

#############################################################
# 3. Cross-VPC Security Group Rules (Frontend <-> Backend)
#############################################################

# --- Backend Private SG 02 <-> Frontend Private SG 02 ---

resource "aws_vpc_security_group_ingress_rule" "be_private_sg02_allow_ssh_from_fe_private_sg02" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg02_id
  referenced_security_group_id = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg02_id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "be_private_sg02_allow_icmp_from_fe_private_sg02" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg02_id
  referenced_security_group_id = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg02_id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}

resource "aws_vpc_security_group_egress_rule" "be_private_sg02_allow_ssh_to_fe_private_sg02" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg02_id
  referenced_security_group_id = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg02_id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "be_private_sg02_allow_icmp_to_fe_private_sg02" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg02_id
  referenced_security_group_id = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg02_id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg02_allow_ssh_from_be_private_sg02" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg02_id
  referenced_security_group_id = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg02_id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg02_allow_icmp_from_be_private_sg02" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg02_id
  referenced_security_group_id = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg02_id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}

resource "aws_vpc_security_group_egress_rule" "fe_private_sg02_allow_ssh_to_be_private_sg02" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg02_id
  referenced_security_group_id = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg02_id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "fe_private_sg02_allow_icmp_to_be_private_sg02" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg02_id
  referenced_security_group_id = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg02_id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}

# --- Backend Private SG 03 <-> Frontend Private SG 03 ---

resource "aws_vpc_security_group_ingress_rule" "be_private_sg03_allow_ssh_from_fe_private_sg03" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg03_id
  referenced_security_group_id = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg03_id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "be_private_sg03_allow_icmp_from_fe_private_sg03" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg03_id
  referenced_security_group_id = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg03_id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}

resource "aws_vpc_security_group_egress_rule" "be_private_sg03_allow_ssh_to_fe_private_sg03" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg03_id
  referenced_security_group_id = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg03_id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "be_private_sg03_allow_icmp_to_fe_private_sg03" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg03_id
  referenced_security_group_id = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg03_id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg03_allow_ssh_from_be_private_sg03" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg03_id
  referenced_security_group_id = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg03_id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "fe_private_sg03_allow_icmp_from_be_private_sg03" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg03_id
  referenced_security_group_id = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg03_id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}

resource "aws_vpc_security_group_egress_rule" "fe_private_sg03_allow_ssh_to_be_private_sg03" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg03_id
  referenced_security_group_id = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg03_id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "fe_private_sg03_allow_icmp_to_be_private_sg03" {
  depends_on                   = [aws_vpc_peering_connection.fevpc_peering_bevpc]
  security_group_id            = data.terraform_remote_state.frontend_security_groups.outputs.fe_private_sg03_id
  referenced_security_group_id = data.terraform_remote_state.backend_security_groups.outputs.be_private_sg03_id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = 0
}
