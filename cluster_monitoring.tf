resource "rancher2_app_v2" "cluster_monitoring" {
  chart_name = "rancher-monitoring"
  cluster_id = rancher2_cluster_v2.rke2.cluster_v1_id
  name       = "rancher-monitoring"
  namespace  = "cattle-monitoring-system"
  project_id = data.rancher2_project.system.id
  repo_name  = "rancher-charts"
  values     = <<EOF
    global:
      cattle:
        systemProjectId: ${data.rancher2_project.system.id}
        url: ${file("${path.cwd}/files/.rancher-api-url")}
    prometheusSpec:
      resources:
        limits:
          cpu: 500m
          memory: 512Mi
        requests:
          cpu: 250m
          memory: 256Mi
    rke2ControllerManager:
      enabled: true
    rke2Etcd:
      enabled: true
    rke2IngressNginx: # Disable this because baked-in NGiNX Ingress is not used here
      enabled: false
    rke2Proxy:
      enabled: false # Disable this because we have no proxy to monitor!
    rke2Scheduler:
      enabled: true
  EOF
}

resource "rancher2_config_map_v2" "haproxy_dashboard" {
  cluster_id = rancher2_cluster_v2.rke2.cluster_v1_id
  name       = "haproxy-dashboard"
  labels     = { "grafana_dashboard" = "1" }
  namespace  = "cattle-dashboards"
  data = {
    "haproxy-ingress-dashboard.json" = file("${path.cwd}/files/haproxy_ingress_dashboard.json")
  }

  depends_on = [
    rancher2_app_v2.cluster_monitoring
  ]
}