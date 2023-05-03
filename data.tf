data "http" "haproxy_grafana_dashboard" {
  url = "https://raw.githubusercontent.com/frank-at-suse/vsphere_cilium_kubeproxy-less/master/files/haproxy_ingress_dashboard.json"
}

data "http" "kube_vip_rbac" {
  url = "https://kube-vip.io/manifests/rbac.yaml"
}

data "http" "kube_vip_version" {
  method = "GET"
  url    = "https://api.github.com/repos/kube-vip/kube-vip/releases/latest"
}

data "rancher2_cloud_credential" "auth" {
  name = var.rancher_env.cloud_credential
}

data "rancher2_namespace" "kube_system" {
  name       = "kube-system"
  project_id = data.rancher2_project.system.id
}

data "rancher2_project" "system" {
  name       = "System"
  cluster_id = rancher2_cluster_v2.rke2.cluster_v1_id
}