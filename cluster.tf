resource "random_pet" "cluster_name" {
  length = 2
}

resource "rancher2_machine_config_v2" "nodes" {
  for_each      = var.node
  generate_name = replace(each.value.name, "_", "-")

  vsphere_config {
    cfgparam   = ["disk.enableUUID=TRUE"]
    clone_from = var.vsphere_env.cloud_image_name
    cloud_config = templatefile("${path.cwd}/files/user_data.tftmpl",
      {
        ssh_user       = "rancher",
        ssh_public_key = file("${path.cwd}/files/.ssh-public-key")
    }) # End of templatefile
    content_library = var.vsphere_env.library_name
    cpu_count       = each.value.vcpu
    creation_type   = "library"
    datacenter      = var.vsphere_env.datacenter
    datastore       = var.vsphere_env.datastore
    disk_size       = each.value.hdd_capacity
    memory_size     = each.value.vram
    network         = [each.value.vm_network]
    vcenter         = var.vsphere_env.server
  }
} # End of rancher2_machine_config_v2

resource "rancher2_cluster_v2" "rke2" {
  annotations        = var.rancher_env.cluster_annotations
  kubernetes_version = var.rancher_env.rke2_version
  labels             = var.rancher_env.cluster_labels
  name               = random_pet.cluster_name.id

  rke_config {
    additional_manifest = templatefile("${path.cwd}/files/additional_manifests.tftmpl",
      {
        bgp_local_as     = var.kubevip.local_as
        bgp_peer_router  = var.kubevip.peer_router
        bgp_remote_as    = var.kubevip.remote_as
        interface_name   = var.kubevip.interface_name
        kube_vip_version = var.kubevip.version
        svc_lb_vip       = var.kubevip.lb_vip
    })

    chart_values = <<-EOF
      rke2-cilium:
        bandwidthManager:
          bbr: true
          enabled: true
        bpf:
          hostLegacyRouting: false
          masquerade: true
        cluster:
          name: ${random_pet.cluster_name.id}
        externalIPs:
          enabled: true
        hostPort:
          enabled: true
        k8sServiceHost: 127.0.0.1
        k8sServicePort: 6443
        kubeProxyReplacement: strict
        loadBalancer:
          algorithm: maglev
        nodePort:
          enabled: true
        operator:
          replicas: 1
    EOF

    machine_global_config = <<EOF
      cni: "cilium"
      disable: [ "rke2-ingress-nginx" ]
      disable-kube-proxy: "true"
      etcd-arg: [ "experimental-initial-corrupt-check=true" ] # Can be removed once etcd v3.6 enables corruption check by default (see: https://github.com/etcd-io/etcd/issues/13766)
      kube-controller-manager-arg: [ "allocate-node-cidrs" ]
      kubelet-arg: [ "cgroup-driver=systemd" ]
      write-kubeconfig-mode: "0644"
    EOF

    dynamic "machine_pools" {
      for_each = var.node
      content {
        cloud_credential_secret_name = data.rancher2_cloud_credential.auth.id
        control_plane_role           = machine_pools.key == "ctl_plane" ? true : false
        etcd_role                    = machine_pools.key == "ctl_plane" ? true : false
        name                         = machine_pools.value.name
        quantity                     = machine_pools.value.quantity
        worker_role                  = machine_pools.key != "ctl_plane" ? true : false

        machine_config {
          kind = rancher2_machine_config_v2.nodes[machine_pools.key].kind
          name = replace(rancher2_machine_config_v2.nodes[machine_pools.key].name, "_", "-")
        }
      } # End of dynamic for_each content
    }   # End of machine_pools

    machine_selector_config {
      config = null
    } # End machine_selector_config
  }   # End of rke_config
}     # End of rancher2_cluster_v2