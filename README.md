# removed need to add properly

resource "aws_route" "prod_to_internet" {
  count                     = length(module.prod_vpc.private_route_table_ids)
  route_table_id            = element(module.prod_vpc.private_route_table_ids, count.index)
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.nat.id  # Correct reference to the NAT gateway
}


Act as a terraform engineer, and build a secure and easy to understand code with supported modular approach keeping all .tf files in same root directory and using variables so that we can do modifications in future as needed.Below are the requirnments:

1. Two VPC ----> Hub VPC and Prod VPC
2. Do peering between them to enable communication
3. HUB VPC will have following configurations -----> Two public subnets only -----> Hub-prod-public-LB-SN and Hub-admin-public-SN
4. It will have one route table -----> HUB-VPC-PUBRT ----> one route to 0.0.0.0/0 using internet gateway and second route to Prod VPC
5. Hub-prod-public-LB-SN will have following inbound and outbound rules ----> Inbound from 0.0.0.0 on port 80 and 443 and outbound to Prod-private-SN1 & Prod-private-SN2 on prot 80 and 443
6. PROD VPC will have following configurations -----> Two private subnets only -----> Prod-private-SN1 and Prod-private-SN2
7. It will have one route table -----> PROD-VPC-PVTRT ----> one route to 0.0.0.0/0 using nat gateway and second route to Hub VPC
8. Both private subnet in Prod VPC will have following inbound and outbound rules ----> inbound from Hub-prod-public-LB-SN on port 80 and 443 also on port 22 from Hub-admin-public-SN and outbound to 0.0.0.0 on port 80 and 443
9. I need two ec2 instances...one in Hub-admin-public-SN which will act as a jump server so port 80, 443 and 22 outbound to Prod-private-SN1 will be needed
10. another ec2 named bastion server will be in Prod-private-SN1 which will use to connect to eks cluster in prod vpc
11. so the flow will be person will ssh into jump server first than it will ssh into bastion server and than it will connect to eks cluster.

Please review this whole requirnments first, analyze the complete architecure and suggest if some routes or rules can be added or removed to ensure it safe and efficient. EKS creation we will add later.
