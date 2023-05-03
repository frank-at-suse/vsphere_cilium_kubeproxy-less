resource "rancher2_app_v2" "haproxy" {
  chart_name = "haproxy"
  cluster_id = rancher2_cluster_v2.rke2.cluster_v1_id
  name       = "haproxy-ingress"
  namespace  = data.rancher2_namespace.kube_system.id
  repo_name  = "rancher-partner-charts"
  values     = <<EOF
    # Additional config values can be found at: https://www.haproxy.com/documentation/kubernetes/latest/configuration/
    controller:
      daemonset:
        useHostPort: true
      extraArgs:
        - "--empty-ingress-class" # A flag to indicate the controller should process ingresses with empty ingress.class annotation
      ingressClassResource:
        default: true
        enabled: true
      kind: DaemonSet
      publishService: # Copies ingress controller’s IP address to the ‘Address’ field in all Ingress objects that the controller manages
        enabled: true
      service:
        type: LoadBalancer
        loadBalancerIP: ${var.kubevip.lb_vip}
      serviceMonitor:
        enabled: true
    defaultBackend:
      enabled: false
  EOF
}