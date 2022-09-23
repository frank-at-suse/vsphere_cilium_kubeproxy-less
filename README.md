# RKE2 Cluster with kube-proxy -less Cilium CNI & BBR Pod Congestion Control

![Rancher](https://img.shields.io/badge/rancher-%230075A8.svg?style=for-the-badge&logo=rancher&logoColor=white) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) 	![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)

## Reason for Being
This Terraform plan is for creating a kube-proxy -less multi-node RKE2 cluster using [Cilium CNI](https://docs.cilium.io/en/v1.12/).  The Cilium chart enables [BBR Pod Congestion Control](https://docs.cilium.io/en/v1.12/operations/performance/tuning/#bbr-congestion-control-for-pods) for greatly increased network performance as well. Also installed is **Rancher's Prometheus Operator Chart (`cluster_monitoring.tf`)** along with an HAProxy Ingress Grafana Dashboard to gain visibility into your Ingress traffic (this plan disables the built-in RKE2 NGiNX Ingress in favor of HAProxy because...reasons  `¯\_(ツ)_/¯` ). kube-vip makes a token appearance here to advertise the HAProxy Ingress Controller via ARP.

_This is a nice boiler-plate Terraform plan for a high-performing cluster that includes a very capable monitoring stack._


## Environment Prerequisites

- Functional Rancher Management Server with vSphere Cloud Credential
- vCenter >= 7.x and credentials with appropriate permissions (see https://docs.ranchermanager.rancher.io/how-to-guides/new-user-guides/kubernetes-clusters-in-rancher-setup/launch-kubernetes-with-rancher/use-new-nodes-in-an-infra-provider/vsphere/create-credentials)
- Virtual Machine Hardware Compatibility at Version >= 15
- Linux Kernel >= 5.18 (required for enabling [BBR Pod Congestion Control](https://docs.cilium.io/en/v1.12/operations/performance/tuning/#bbr-congestion-control-for-pods))
- Create the following in the files/ directory:

    | NAME | PURPOSE |
    | ------ | ------ |
    | .rancher-api-url | URL for Rancher Management Server
    | .rancher-bearer-token | API bearer token generated via Rancher UI
    | .ssh-public-key | SSH public key for additional OS user

## Caveats
- [Cilium's Hubble UI](https://docs.cilium.io/en/v1.12/gettingstarted/hubble/) is disabled as it can be a [drag on performance](https://docs.cilium.io/en/v1.12/operations/performance/tuning/#hubble).  However, if you enjoy looking at groupings of rectangles connected with lines and _do_ want to enable Hubble, reference the RKE2 Cilium Helm chart [HERE](https://github.com/rancher/rke2-charts/tree/main/charts/rke2-cilium/rke2-cilium).

---
- If you don't want to run the **Rancher Prometheus Operator**, it can be uninstalled at any time simply by removing `cluster_monitoring.tf` from your working directory and re-applying the plan.  It is here as a demonstration/value-add, not a requirement of any kind.

---
- kube-vip is operating via ARP mode, so services published via LoadBalancer _will have traffic directed to a single node_.

---
- Unlike RKE2's "baked-in" NGiNX Ingress Controller, HAProxy's ingress is **not** FIPS 140-2 compliant.

## To Run
    > terraform apply

## Tested Versions

| SOFTWARE | VERSION | DOCS |
| ------ | ------ | ------ |
| kube-vip | 0.5.0 | https://kube-vip.io/docs
| Rancher Prometheus Operator | 100.1.3+up19.0.3 | https://docs.ranchermanager.rancher.io/pages-for-subheaders/monitoring-and-alerting
| Rancher Server | 2.6.8 | https://rancher.com/docs/rancher/v2.6/en/overview
| Rancher Terraform Provider| 1.24.1 | https://registry.terraform.io/providers/rancher/rancher2/latest/docs
| RKE2 | 1.24.4+rke2r1 | https://docs.rke2.io
| Terraform | 1.2.7 | https://www.terraform.io/docs
| vSphere | 7.0.3 Build 20150588 | https://docs.vmware.com/en/VMware-vSphere/index.html