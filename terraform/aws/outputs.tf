# Required to setup Route53
output "vpc_id" {
  value       = [aws_vpc.${CLUSTER_NAME}_vpc.id]
  description = "Vpc ID"
}

# Machines names
output "masters" {
  value       = [aws_instance.${CLUSTER_NAME}-master.*.tags.Name]
  description = "Hostname of masters"
}

output "workers" {
  value       = [aws_instance.${CLUSTER_NAME}-worker.*.tags.Name]
  description = "Hostname of workers"
}

output "workers-stream" {
  value       = [aws_instance.${CLUSTER_NAME}-worker-stream.*.tags.Name]
  description = "Hostname of workers"
}

output "ipa" {
  value       = [aws_instance.${CLUSTER_NAME}-ipa.*.tags.Name]
  description = "Hostname of IPA"
}

output "kts" {
  value       = [aws_instance.${CLUSTER_NAME}-kts.*.tags.Name]
  description = "Hostname of KTS"
}

output "ecs-master" {
  value       = [aws_instance.${CLUSTER_NAME}-ecs-master.*.tags.Name]
  description = "Hostname of ECS Masters"
}

output "ecs-worker" {
  value       = [aws_instance.${CLUSTER_NAME}-ecs-worker.*.tags.Name]
  description = "Hostname of ECS Workers"
}

# Machines Ids
output "masters_ids" {
  value       = [aws_instance.${CLUSTER_NAME}-master.*.id]
  description = "Ids of masters"
}

output "workers_ids" {
  value       = [aws_instance.${CLUSTER_NAME}-worker.*.id]
  description = "Ids of workers"
}

output "workers-stream_ids" {
  value       = [aws_instance.${CLUSTER_NAME}-worker-stream.*.id]
  description = "Ids of workers"
}

output "ipa_ids" {
  value       = [aws_instance.${CLUSTER_NAME}-ipa.*.id]
  description = "Ids of IPA"
}

output "kts_ids" {
  value       = [aws_instance.${CLUSTER_NAME}-kts.*.id]
  description = "Ids of KTS"
}

output "ecs-master_ids" {
  value       = [aws_instance.${CLUSTER_NAME}-ecs-master.*.id]
  description = "Ids of ECS Masters"
}

output "ecs-worker_ids" {
  value       = [aws_instance.${CLUSTER_NAME}-ecs-worker.*.id]
  description = "Ids of ECS Workers"
}



# For external /etc/hosts file use
output "ip_hosts_masters" {
  value = templatefile("hosts.tpl", {
    instances = aws_instance.${CLUSTER_NAME}-master.*
  })
}

output "ip_hosts_workers" {
  value = templatefile("hosts.tpl", {
    instances = aws_instance.${CLUSTER_NAME}-worker.*
  })
}

output "ip_hosts_worker_stream" {
  value = templatefile("hosts.tpl", {
    instances = aws_instance.${CLUSTER_NAME}-worker-stream.*
  })
}

output "ip_hosts_ipa" {
  value = templatefile("hosts.tpl", {
    instances = aws_instance.${CLUSTER_NAME}-ipa.*
  })
}

output "ip_hosts_kts" {
  value = templatefile("hosts.tpl", {
    instances = aws_instance.${CLUSTER_NAME}-kts.*
  })
}

output "ip_hosts_ecs_master" {
  value = templatefile("hosts.tpl", {
    instances = aws_instance.${CLUSTER_NAME}-ecs-master.*
  })
}

output "ip_hosts_ecs_worker" {
  value = templatefile("hosts.tpl", {
    instances = aws_instance.${CLUSTER_NAME}-ecs-worker.*
  })
}


# For internal /etc/hosts file
output "ip_internal_hosts_masters" {
  value = templatefile("hosts_internal.tpl", {
    instances = aws_instance.${CLUSTER_NAME}-master.*
  })
}

output "ip_internal_hosts_workers" {
  value = templatefile("hosts_internal.tpl", {
    instances = aws_instance.${CLUSTER_NAME}-worker.*
  })
}

output "ip_internal_hosts_worker_stream" {
  value = templatefile("hosts_internal.tpl", {
    instances = aws_instance.${CLUSTER_NAME}-worker-stream.*
  })
}

output "ip_internal_hosts_ipa" {
  value = templatefile("hosts_internal.tpl", {
    instances = aws_instance.${CLUSTER_NAME}-ipa.*
  })
}

output "ip_internal_hosts_kts" {
  value = templatefile("hosts_internal.tpl", {
    instances = aws_instance.${CLUSTER_NAME}-kts.*
  })
}

output "ip_internal_hosts_ecs_master" {
  value = templatefile("hosts_internal.tpl", {
    instances = aws_instance.${CLUSTER_NAME}-ecs-master.*
  })
}

output "ip_internal_hosts_ecs_worker" {
  value = templatefile("hosts_internal.tpl", {
    instances = aws_instance.${CLUSTER_NAME}-ecs-worker.*
  })
}
