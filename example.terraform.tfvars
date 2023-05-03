kubevip = {
  interface_name = "ens192"
  lb_vip         = "1.2.3.4"
}

node = {
  ctl_plane = { hdd_capacity = 40960, name = "ctl-plane", quantity = 3, vcpu = 4, vm_network = "VLAN_70", vram = 4096 }
  worker    = { hdd_capacity = 81920, name = "worker", quantity = 3, vcpu = 4, vm_network = "VLAN_70", vram = 8192 }
}

rancher_env = {
  cloud_credential    = "vsphere-credential-name"
  cluster_annotations = { "foo" = "bar" }
  cluster_labels      = { "something" = "amazing" }
  rke2_version        = "v1.25.9+rke2r1"
}

vsphere_env = {
  cloud_image_name = "os-of-your-choice"
  datacenter       = "Datacenter"
  datastore        = "fast"
  library_name     = "rancher-templates"
  server           = "vcenter.ip.or.fqdn"
}