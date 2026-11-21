output "vpc_peering_connection_id" {
  description = "The ID of the VPC Peering Connection"
  value       = aws_vpc_peering_connection.fevpc_peering_bevpc.id
}

output "vpc_peering_accept_status" {
  description = "The status of the VPC Peering Connection request"
  value       = aws_vpc_peering_connection.fevpc_peering_bevpc.accept_status
}
