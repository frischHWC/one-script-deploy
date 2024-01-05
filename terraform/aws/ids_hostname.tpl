%{ for _, instance in instances ~}
${instance.id} ${instance.tags["Name"]}
%{ endfor ~}