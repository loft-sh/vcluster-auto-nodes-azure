# vCluster Auto Nodes Azure

**td;dr**: I just need a `vcluster.yaml` to get started:

```yaml
# vcluster.yaml
controlPlane:
  service:
    spec:
     type: LoadBalancer
privateNodes:
  enabled: true
  autoNodes:
  - provider: ms-azure
    dynamic:
    - name: az-cpu-nodes
      nodeTypeSelector:
      - property: instance-type
        operator: In
        values: ["Standard_D2s_v5", "Standard_D4s_v5", "Standard_D8s_v5"]
```

## Overview

Terraform modules for provisioning **Auto Nodes on Azure**.  
These modules dynamically create Azure VMs as vCluster Private Nodes, powered by **Karpenter**.

### Key Features

- **Dynamic provisioning** – Nodes automatically scale up or down based on pod requirements  
- **Multi-cloud support** – Run vCluster nodes across Azure, AWS, GCP, on-premises, or bare metal  
  - CSI configuration in multi-cloud environments requires manual setup.
- **Cost optimization** – Provision only the resources you actually need  
- **Simple configuration** – Define node requirements directly in your `vcluster.yaml`  

By default, this quickstart **NodeProvider** isolates each vCluster into its own Virtual Network (VNet).

---

## Resources Created Per Virtual Cluster

### [Infrastructure](./environment/infrastructure)

- A dedicated Virtual Network (VNet)  
- Public subnets in two Availability Zones  
- Private subnets in two Availability Zones  
- A NAT Gateway for the private subnets  
- A Network Security Group (NSG) for worker nodes  
- A managed identity for worker nodes  
  - Permissions/role assignments depend on whether CCM and CSI are enabled  

### [Kubernetes](./environment/kubernetes)

- Cloud Controller Manager for node initialization and automatic LoadBalancer creation  
- **Azure Disk CSI** driver with a default storage class  
  - The default storage class does **not** enforce allowed topologies (important in multi-cloud setups). You can provide your own.  

### [Nodes](./node/)

- Azure VMs using the selected `instance-type`, attached to private subnets  

---

## Getting started

### Prerequisites

1. Access to an Azure account
2. A host kubernetes cluster, preferrably on AKS to use Workload Identity
3. vCluster Platform running in the host cluster. [Get started](https://www.vcluster.com/docs/platform/install/quick-start-guide)
4. (optional) The [vCluster CLI](https://www.vcluster.com/docs/vcluster/#deploy-vcluster)
5. (optional) Authenticate the vCluster CLI `vcluster platform login $YOUR_PLATFORM_HOST`

### Setup

#### Step 1: Configure Node Provider

Define your Azure Node Provider in the vCluster Platform. This provider manages the lifecycle of Azure VM nodes.

In the vCluster Platform UI, navigate to "Infra > Nodes", click on "Create Node Provider" and then use "Microsoft Azure".
Specify a subscription ID in which all resources will be created. You can optionally set a default region and default resource group. This can still be changed on a per virtual cluster basis later on.

#### Step 2: Authenticate the Node Provider

Auto Nodes supports two authentication methods for Azure resources. **Workload Identity is strongly recommended** for production use.

##### Option A: Workload Identity (Recommended)

[Configure AKS Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview?tabs=dotnet) to grant the vCluster control plane permissions to manage Azure VMs.
Then, assign the [the quickstart role](./docs/auto_nodes_role.json) to your Workload Identity Service Principal to authenticate the terraform provider to create environments and nodes. Please adjust the `assignableScopes` section to match your subscription or resource group before creating the role.

##### Option B: Manual secrets

If Workload Identity is not available, use a kubernetes secret with static credentials to authenticate against Azure.
You can create this secret from the vCluster Platform UI by choosing "specify credentials inline" in the Quickstart setup, or manually later on:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ms-azure-credentials
  namespace: vcluster-platform
  labels:
    terraform.vcluster.com/provider: "ms-azure" # This has to match your provider name
stringData:
    ARM_CLIENT_ID: ''
    ARM_CLIENT_SECRET: ''
    ARM_TENANT_ID: ''
    ARM_SUBSCRIPTION_ID: ''
EOF
```

This secret uses a Service Principal with Client Secret to authenticate agains Azure. Please consult the [terraform provider docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure) for alternative authentication methods.

Ensure the Service Principal has at least the permissions outlined in [the auto nodes role](./docs/auto_nodes_role.json).

#### Step 3: Create virtual cluster

This vcluster.yaml file defines a Private Node Virtual Cluster with Auto Nodes enabled. It exposes the control plane through a LoadBalancer on the AKS host cluster. This is required for individual Azure VMs to join the cluster.

```yaml
# vcluster.yaml
controlPlane:
  service:
    spec:
     type: LoadBalancer

privateNodes:
  enabled: true
  autoNodes:
    provider: ms-azure
    dynamic:
    - name: az-cpu-nodes
      nodeTypeSelector:
      - property: instance-type
        operator: In
        values: ["Standard_D2s_v5", "Standard_D4s_v5", "Standard_D8s_v5"]
      limits:
        cpu: "100"
        memory: "200Gi"
```

Create the virtual cluster through the vCluster Platform UI or the vCluster CLI:

 `vcluster platform create vcluster az-private-nodes -f ./vcluster.yaml --project default`

## Advanced configuration

### NodeProvider configuration options

You can configure the **NodeProvider** with the following options:

| Option                        | Default       | Description                                                                                 |
| ----------------------------- | ------------- | ------------------------------------------------------------------------------------------- |
| `vcluster.com/ccm-enabled`    | `true`        | Enables deployment of the Cloud Controller Manager.                                         |
| `vcluster.com/ccm-lb-enabled` | `true`        | Enables the CCM service controller. If disabled, CCM will not create LoadBalancer services. |
| `vcluster.com/csi-enabled`    | `true`        | Enables deployment of the CSI driver with a `<provider>-default-disk` storage class.                 |
| `vcluster.com/vpc-cidr`       | `10.5.0.0/16` | Sets the VPC CIDR range. Useful in multi-cloud scenarios to avoid CIDR conflicts.           |

## Example

```yaml
controlPlane:
  service:
    spec:
     type: LoadBalancer
privateNodes:
  enabled: true
  autoNodes:
  - provider: ms-azure
    properties:
      vcluster.com/ccm-lb-enabled: "false"
      vcluster.com/csi-enabled: "false"
      vcluster.com/vpc-cidr: "10.15.0.0/16"
    dynamic:
    - name: az-cpu-nodes
      nodeTypeSelector:
      - property: instance-type
        operator: In
        values: ["Standard_D2s_v5", "Standard_D4s_v5", "Standard_D8s_v5"]
```

## Security considerations

> **_NOTE:_** When deploying [Cloud Controller Manager (CCM)](https://kubernetes.io/docs/concepts/architecture/cloud-controller/) and [Container Storage Interface (CSI)](https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/) with Auto Nodes, permissions are granted through user assigned managed identity.
**This means all worker nodes inherit the same permissions as CCM and CSI.**
As a result, **any pod the cluster could potentially access the same cloud permissions**.
Refer to the full [list of permissions](environment/infrastructure/identity.tf) for details.

Cluster administrators should be aware of the following:

- **Shared permissions** – all pods running in a **host network** may gain the same access level as CCM and CSI.  
- **Mitigation** – cluster administrators can disable CCM and CSI deployments.  
  In that case, virtual machines will not be granted additional permissions.  
  However, responsibility for deploying and securely configuring CCM and CSI will then fall to the cluster administrator.  

> **_NOTE:_** Security-sensitive environments should carefully review which permissions are granted to clusters and consider whether CCM/CSI should be disabled and managed manually.

## Limitations

### Hybrid-cloud and multi-cloud

When running a vCluster across multiple providers, some additional configuration is required:

- **CSI drivers** – Install and configure the appropriate CSI driver for Azure cloud provider.  
- **StorageClasses** – Use `allowedTopologies` to restrict provisioning to valid zones/regions.  
- **NodePools** – Add matching zone labels **only when zones are in use** so the scheduler can place pods on nodes with storage in the same zone.  

For details on multi-cloud setup, see the [Deploy](https://www.vcluster.com/docs/vcluster/deploy/worker-nodes/private-nodes/auto-nodes/quick-start-templates#deploy) and [Limits](https://www.vcluster.com/docs/vcluster/deploy/worker-nodes/private-nodes/auto-nodes/quick-start-templates#hybrid-cloud-and-multi-cloud) vCluster documentation.

#### Example: Azure Disk StorageClass with zones (only if you use zones)

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-disk-zonal
provisioner: disk.csi.azure.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  skuName: Premium_LRS
allowedTopologies:
  - matchLabelExpressions:
      - key: topology.disk.csi.azure.com/zone
        values: ["westeurope-1", "westeurope-2"]
```

### Region changes

Changing the region of an existing node pool is not supported.
To switch regions, create a new virtual cluster and migrate your workloads.

### Dynamic nodes `Limit`

When editing the limits property of dynamic nodes, any nodes that already exceed the new limit will **not** be removed automatically.
Administrators are responsible for manually scaling down or deleting the excess nodes.
