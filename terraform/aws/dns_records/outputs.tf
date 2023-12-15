# For external /etc/hosts file use
output "hosts_ips" {
  value = templatefile("hosts_eip.tpl", {
    instances = aws_eip.hosts_elastic_ips
  })
}