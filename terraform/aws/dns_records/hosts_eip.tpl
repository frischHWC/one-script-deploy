%{ for _, instance in instances ~}
${instance.public_ip} ${instance.tags["Name"]}
%{ endfor ~}