output "hub_vpc_id" {
  value = module.hub_vpc.vpc_id
}

output "prod_vpc_id" {
  value = module.prod_vpc.vpc_id
}

output "jump_server_public_ip" {
  value = module.jump_server.public_ip
}

output "bastion_server_private_ip" {
  value = module.bastion_server.private_ip
}
