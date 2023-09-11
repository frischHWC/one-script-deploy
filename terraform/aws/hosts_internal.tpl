%{ for _, instance in instances ~}
${instance.private_ip} ${instance.tags["Name"]}
%{ endfor ~}