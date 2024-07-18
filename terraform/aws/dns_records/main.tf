# Make a map of all machines with their private IPs
variable "hostname_private_ip_map" {
  type    = map(string)
  default = {
    ${HOST_NAME_IP_MAP}
  }
}

variable "machines_ids" {
  type    = map(string)
  default = {
    ${HOST_NAME_MACHINES_ID_MAP}
  }
}

variable "is_pvc" {
  type    = bool
  default = ${IS_PVC}
}

# NETWORK RESOURCES

resource "aws_route53_zone" "${CLUSTER_NAME}_zone" {
  name = "${DOMAIN_NAME}" 
  vpc {
    vpc_id              = "${VPC_ID}"
    vpc_region          = "${REGION}"
  }
  tags = {
    Owner = "${RESOURCE_OWNER}"
  }
}

# Create route to first DNS record
resource "aws_route53_record" "domain_record" {
  zone_id = aws_route53_zone.${CLUSTER_NAME}_zone.zone_id
  name    = "${DOMAIN_NAME}"
  type    = "A"
  ttl     = "300"
  records = ["${FIRST_MASTER_IP}"]
}

# Create routes to first ECS Master AS Control Plane
resource "aws_route53_record" "ecs_domain_record" {
  count = var.is_pvc == true ? 1 : 0
  zone_id = aws_route53_zone.${CLUSTER_NAME}_zone.zone_id
  name    = "console-cdp.apps.${ECS_MASTER_NODE_1}"
  type    = "A"
  ttl     = "300"
  records = ["${ECS_MASTER_1_IP}"]
}
resource "aws_route53_record" "ecs_wild_domain_record" {
  count = var.is_pvc == true ? 1 : 0
  zone_id = aws_route53_zone.${CLUSTER_NAME}_zone.zone_id
  name    = "*.apps.${ECS_MASTER_NODE_1}"
  type    = "A"
  ttl     = "300"
  records = ["${ECS_MASTER_1_IP}"]
}


# Create DNS records for ALL machines with normal and wildcard record
resource "aws_route53_record" "hosts_records" {
  for_each = var.hostname_private_ip_map
  zone_id = aws_route53_zone.${CLUSTER_NAME}_zone.zone_id
  name    = each.key 
  type    = "A"
  ttl     = "300"
  records = [each.value]
}

resource "aws_route53_record" "hosts_wildcard_records" {
  for_each = var.hostname_private_ip_map
  zone_id = aws_route53_zone.${CLUSTER_NAME}_zone.zone_id
  name    = format("%s.%s", "*", each.key) 
  type    = "A"
  ttl     = "300"
  records = [each.value]
}

# Add elastic IP for each machine
resource "aws_eip" "hosts_elastic_ips" {
  for_each = var.machines_ids
  instance = each.value
  domain   = "vpc"
  tags = {
    Name = each.key,
    Owner = "${RESOURCE_OWNER}"
  }
}

# TODO: Add PTR records for reverse dns records

