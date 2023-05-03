resource "rancher2_config_map_v2" "haproxy_dashboard" {
  cluster_id = rancher2_cluster_v2.rke2.cluster_v1_id
  name       = "haproxy-dashboard"
  labels     = { "grafana_dashboard" = "1" }
  namespace  = "cattle-dashboards"
  data = {
    "haproxy-ingress-dashboard.json" = data.http.haproxy_grafana_dashboard.response_body
  }

  depends_on = [
    rancher2_app_v2.cluster_monitoring
  ]
}