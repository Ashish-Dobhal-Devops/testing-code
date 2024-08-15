output "hub_vpc_id" {
  value = module.hub_vpc.vpc_id
}

output "prod_vpc_id" {
  value = module.prod_vpc.vpc_id
}

output "hub_public_subnet_ids" {
  value = module.hub_vpc.public_subnets
}

output "prod_private_subnet_ids" {
  value = module.prod_vpc.private_subnets
}

output "jump_server_id" {
  value = module.jump_server.id # Adjusted attribute name
}

output "bastion_server_id" {
  value = module.bastion_server.id # Adjusted attribute name
}

output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.hub_prod.id
}

output "jump_server_public_ip" {
  value = module.jump_server.public_ip
}

output "bastion_server_private_ip" {
  value = module.bastion_server.private_ip
}
