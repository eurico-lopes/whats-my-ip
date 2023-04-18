locals {
  name                        = "whats-my-ip"
  namespace                   = "whats-my-ip"
  resource_requests_cpu       = "500m"
  resource_requests_memory_mb = 500
  resource_limits_cpu         = "500m"
  resource_limits_memory_mb   = 500
  replicas                    = 3
  node_port                   = 32099
  port                        = 8000
  target_port                 = 8000
  image                       = "${var.docker_id}/whats_my_ip:${data.shell_script.tag.output["value"]}"
}

data "shell_script" "tag" {
  lifecycle_commands {
    read = <<-EOF
      GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
      echo "{\"value\": \"$(bash $GIT_REPO_ROOT/scripts/get-tag.sh)\"}"
    EOF
  }
}

resource "kubectl_manifest" "namespace" {
  yaml_body = templatefile("${path.module}/../k8s/namespace.yaml", {
    namespace = local.namespace
  })

}

resource "kubectl_manifest" "deployment" {
  yaml_body = templatefile("${path.module}/../k8s/deployment.yaml", {
    name                        = local.name
    namespace                   = local.namespace
    image                       = local.image
    resource_requests_cpu       = local.resource_requests_cpu
    resource_requests_memory_mb = local.resource_requests_memory_mb
    resource_limits_cpu         = local.resource_limits_cpu
    resource_limits_memory_mb   = local.resource_limits_memory_mb
    replicas                    = local.replicas
    container_port              = local.target_port
  })

  depends_on = [
    kubectl_manifest.namespace
  ]
}

resource "kubectl_manifest" "nodeport" {
  yaml_body = templatefile("${path.module}/../k8s/nodeport.yaml", {
    name        = local.name
    namespace   = local.namespace
    node_port   = local.node_port
    port        = local.port
    target_port = local.target_port
  })

  depends_on = [
    kubectl_manifest.namespace
  ]
}
