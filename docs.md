# GPU Server

## Brief Overview

The GPU Server is a linux machine hosted by Metrostar in Reston, VA. The primary use case for the machine is to use as CI service for GPU dependent applications. The machine configuration is listed below:

- Model: AMD EPYC 7352 24-Core Processor
- Arch: x86_64, 32-bit, 64-bit
- 48 Cores
- ~500 GB Memory
- 6 x NVIDA Tesla V100


# Architecture

![arch](https://github.com/Quansight/open-gpu-server/assets/5647941/3441d6dd-5dc5-4137-affc-25a066656e45)


- The GPU Server is behind Metrostar VPN, the credentials for the same can be obtained from Kevin from Metrostar.
- The GPU Server runs [OpenStack](https://docs.openstack.org/kolla/latest/) and it's services inside docker containers, which provides a way to spinup isloated VMs which can be used for CI/Testing/Development/Sandbox environment.
- The deployment of OpenStack uses [Kolla](https://docs.openstack.org/kolla/latest/), which provides provide production-ready containers and deployment tools for deploying OpenStack Cloud.
- The CI is powered by [cirun.io](https://cirun.io). Cirun is a service to spinup GitHub Actions Runners on a cloud provider (OpenStack in this case).
- The OpenStack web interface is accesible at: [ci.quansight.dev](ci.quansight.dev/). The admin access is with Amit & Jaime at the moment.

## Runner Creation Flow

Cirun application is installed on a GitHub repository, which authorises it to listen to webhook events. Whenever there is a
GitHub Actions workflow job, cirun receives a webhook event, which contains the label for the requested runners. Cirun then
reads the cirun cofniguration file to find our the full runner configuration such as cloud, image, instance type, etc.

Cirun then makes a request to the given cloud provider (OpenStack in this case) to create a runner. The request full provisioning
configuration to spinup the runner and connect it to the github repository and run the requested job. OpenStack when recieved the API
request creates a VM for the job and deletes the VM when it recieves another request from Cirun when the job is completed.

## Accessing OpenStack API on GPU Server

The GPU server is inside a VPN, which means we cannot access it outside the VPN. Cirun needs access to the OpenStack API to be able
to create and destroy runners (VMs). To tackle this problem we have created a proxy server on GCP whose IP address is whitelisted
in the VPN, so that it can access the GPU server from outside the VPN.

The proxy server points to [ci.quansight.dev](https://ci.quansight.dev), apart from providing a gateway to the gpu server it also proxies request to the
gpu server, which is basically being able to access the OpenStack API.


## IOMMU & IOMMU Groups

The **Input-Output Memory Management Unit (IOMMU)** is a component in a memory controller that translates device virtual addresses
(can be also called I/O addresses or device addresses) to physical addresses. The concept of IOMMU is similar to Memory Management Unit (MMU).

The difference between IOMMU and MMU is that IOMMU translates device virtual addresses to physical addresses while MMU translates
CPU virtual addresses to physical addresses.

An **IOMMU group** is the smallest set of physical devices that can be passed to a virtual machine.

## GPUs and it's accesibility

There are 6 x GPUs attached to the GPU server. They are in distributed in 4 IOMMU groups, as shows below:

```
IOMMU Group 19 27:00.0 3D controller [0302]: NVIDIA Corporation GV100GL [Tesla V100 PCIe 16GB] [10de:1db4] (rev a1)
IOMMU Group 19 28:00.0 3D controller [0302]: NVIDIA Corporation GV100GL [Tesla V100 PCIe 16GB] [10de:1db4] (rev a1)
IOMMU Group 32 44:00.0 3D controller [0302]: NVIDIA Corporation GV100GL [Tesla V100 PCIe 16GB] [10de:1db4] (rev a1)
IOMMU Group 75 a3:00.0 3D controller [0302]: NVIDIA Corporation GV100GL [Tesla V100 PCIe 16GB] [10de:1db4] (rev a1)
IOMMU Group 87 c3:00.0 3D controller [0302]: NVIDIA Corporation GV100GL [Tesla V100 PCIe 16GB] [10de:1db4] (rev a1)
IOMMU Group 87 c4:00.0 3D controller [0302]: NVIDIA Corporation GV100GL [Tesla V100 PCIe 16GB] [10de:1db4] (rev a1)
```

Devices in the same IOMMU group can not to attached to different VMs. For e.g. GPUs with address `27:00.0` and `28:00.0` are
in same IOMMU group **19**, which means they cannot be attached to two separate VMs, for this reason, we can spin up upto 4 VMs with at least one GPU each.

The way we access these specific GPUs is by configuring openstack to only load the following GPU addresses for VM creations (when GPU is requested), below is the sample configuration from nova service from openstack for selecting specific GPUs:

```conf
# nova.conf
[pci]
device_spec = [{"address": "a3:00.0"}, {"address": "c3:00.0"}, {"address": "27:00.0"}, {"address": "44:00.0"}]
```

## GPU Passthrough

The GPUs need to be passed to OpenStack VMs via GPU passthrough, we enabled it in two places:

- By checking the **SVM Mode** in the BIOS setting.
- Enable it in the GRUB by editing `/etc/default/grub`
```
GRUB_CMDLINE_LINUX_DEFAULT="amd_iommu=on iommu=pt vfio-pci.ids=10de:1db4 vfio_iommu_type1.allow_unsafe_interrupts=1 modprobe.blacklist=nvidiafb,nouveau"
```

This also prevents NVIDIA drivers to directly access the GPUs from the GPU server, as they need to be passed to the VMs
created by OpenStack instead and hence detected by the NVIDIA drivers in those VMs.

# OpenStack

## Images

OpenStack needs VM image(s) to spinup VMs to be based on. We
use a tool called [Diskimage-builder](https://docs.openstack.org/diskimage-builder/latest/) for building images for our OpenStack installation.

The scripts for the same is available here: https://github.com/aktech/nvidia-openstack-image

## Flavors

Flavors define the compute, memory, and storage capacity and attached PCI devices (GPU in this case) for creation of a VM.
We have defined a bunch of flavors for different use cases like GPU/CPU, Low/High Memory/cores runners. They can be
created via `openstack flavor` command. Example:

```bash
openstack flavor create --public gpu_4xlarge --id gpu_4xlarge --ram 65536 --disk 60 --vcpus 8
openstack flavor set gpu_4xlarge --property  "pci_passthrough:alias"="tesla-v100:1"
```

Below are the currently available flavors:

### GPU Flavors

| Name          | vCPUs | RAM  | Disk  | GPUs                 |
| ------------  | ----- | ---- | ----- | -------------------- |
| `gpu_tiny`    | 4     | 2GB  | 20GB  | 1x NVIDIA Tesla V100 |
| `gpu_medium`  | 4     | 8GB  | 50GB  | 1x NVIDIA Tesla V100 |
| `gpu_large`   | 4     | 12GB | 60GB  | 1x NVIDIA Tesla V100 |
| `gpu_xlarge`  | 8     | 16GB | 60GB  | 1x NVIDIA Tesla V100 |
| `gpu_2xlarge` | 8     | 32GB | 60GB  | 1x NVIDIA Tesla V100 |
| `gpu_4xlarge` | 8     | 64GB | 60GB  | 1x NVIDIA Tesla V100 |


### CPU Flavors

| Name          | vCPUs | RAM  | Disk  |
| ------------  | ----- | ---- | ----- |
| `ci_medium`  | 4     | 8GB  | 60GB   |
| `ci_large`   | 4     | 12GB | 60GB   |


## OpenStack Services

Here is a list of core OpenStack services with brief summaries.

- Cinder: Block Storage service for providing volumes to Nova virtual machines 
- Nova: responsible for provisioning of compute instances
- Horizon: Web based user interface to OpenStack services
- Keystone: Identity and authentication for all OpenStack services.
- Glance: Compute image repository
- Neutron: responsible for provisioning the virtual or physical networks that compute instances connect to on boot.
- Placement: responsible for tracking inventory of resources available in a cloud and assisting in choosing which 

More about these can be read on OpenStack documentation

## Resource Quotas

### Query quota

The resource quota(s) for OpenStack can be seen via the following
command:

```bash
openstack quota show --default
```

### Update quota

The resource quota(s) can be updated via the following command (example below is to update max instance count that can be spun up):

```
openstack quota set --class --instances 15 default
```

# Deployment

The OpenStack setup is deployed via [Kolla Ansible](https://docs.openstack.org/kolla-ansible/latest/), which allows deploying
OpenStack with a single command via ansible. All the configuration is done via a single global configuration file.
More information on deployment can be found on the deployment repository: https://github.com/aktech/gpu-server-openstack-config (TODO: Move repo to quansight.)

# Links

- https://ci.quansight.dev/
- https://docs.openstack.org/nova/latest/
- https://docs.cirun.io
- https://github.com/aktech/gpu-server-openstack-config
- https://github.com/aktech/nvidia-openstack-image
- https://docs.openstack.org/kolla-ansible/latest/
- https://docs.openstack.org/diskimage-builder/latest/
