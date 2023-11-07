# Make a map of all machines with their private IPs
variable "hostname_private_ip_map" {
  type    = map(string)
  default = {
    ${HOST_NAME_IP_MAP}
  }
}

variable "machines_ids" {
  type    = set(string)
  default = toset([ ${MACHINES_IDS} ])
}

# NETWORK RESOURCES

resource "aws_route53_zone" "${CLUSTER_NAME}_zone" {
  name = "${DOMAIN_NAME}" 
  vpc {
    vpc_id              = "${VPC_ID}"
    vpc_region          = "${REGION}"
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

# TODO: Add elastic IP for each machine
resource "aws_eip" "hosts_elastic_ips" {
  for_each = var.machines_ids
  instance = each.key
}

# TODO: Add PTR records for reverse dns records

