# OpenStack setup

The GPU Server runs [OpenStack](https://docs.openstack.org/kolla/latest/). Its [services](#openstack-services) run via Docker containers, which provides a way to spin up isolated VMs which can be used for CI, testing,development, or sandbox environments.

## Deploying OpenStack

The deployment of OpenStack uses [Kolla](https://docs.openstack.org/kolla/latest/), which provides provide production-ready containers and deployment tools for deploying OpenStack Cloud.

The OpenStack setup is deployed via [Kolla Ansible](https://docs.openstack.org/kolla-ansible/latest/), which allows deploying
OpenStack with a single command via ansible. All the configuration is done via a single global configuration file.
More information on deployment can be found on the deployment repository: https://github.com/aktech/gpu-server-openstack-config (TODO: Move repo to quansight.)

## Configuring access to GPUs

### Passthrough

The GPUs need to be passed to OpenStack VMs via GPU passthrough, we enabled it in two places:

- By checking the **SVM Mode** in the BIOS setting.
- GRUB, by editing `/etc/default/grub`:

```
GRUB_CMDLINE_LINUX_DEFAULT="amd_iommu=on iommu=pt vfio-pci.ids=10de:1db4 vfio_iommu_type1.allow_unsafe_interrupts=1 modprobe.blacklist=nvidiafb,nouveau"
```

This also prevents NVIDIA drivers to directly access the GPUs from the GPU server, as they need to be passed to the VMs
created by OpenStack instead and hence detected by the NVIDIA drivers in those VMs.

> Note these `vfio-pci.ids` match the device IDs in the output below.

### IOMMU groups

There are 6 x GPUs attached to the GPU server. They are in distributed in 4 IOMMU groups, as shows below:

```
IOMMU Group 19 27:00.0 3D controller [0302]: NVIDIA Corporation GV100GL [Tesla V100 PCIe 16GB] [10de:1db4] (rev a1)
IOMMU Group 19 28:00.0 3D controller [0302]: NVIDIA Corporation GV100GL [Tesla V100 PCIe 16GB] [10de:1db4] (rev a1)
IOMMU Group 32 44:00.0 3D controller [0302]: NVIDIA Corporation GV100GL [Tesla V100 PCIe 16GB] [10de:1db4] (rev a1)
IOMMU Group 75 a3:00.0 3D controller [0302]: NVIDIA Corporation GV100GL [Tesla V100 PCIe 16GB] [10de:1db4] (rev a1)
IOMMU Group 87 c3:00.0 3D controller [0302]: NVIDIA Corporation GV100GL [Tesla V100 PCIe 16GB] [10de:1db4] (rev a1)
IOMMU Group 87 c4:00.0 3D controller [0302]: NVIDIA Corporation GV100GL [Tesla V100 PCIe 16GB] [10de:1db4] (rev a1)
```

<details>

<summary>What is an IOMMU group?</summary>

The **Input-Output Memory Management Unit (IOMMU)** is a component in a memory controller that translates device virtual addresses
(can be also called I/O addresses or device addresses) to physical addresses. The concept of IOMMU is similar to Memory Management Unit (MMU).

The difference between IOMMU and MMU is that IOMMU translates device virtual addresses to physical addresses while MMU translates
CPU virtual addresses to physical addresses.

An **IOMMU group** is the smallest set of physical devices that can be passed to a virtual machine.

</details>

Devices in the same IOMMU group can not to attached to different VMs. For example, GPUs with address `27:00.0` and `28:00.0` are
in same IOMMU group **19**, which means they cannot be attached to two separate VMs. For this reason, we can spin up upto 4 VMs with at least one GPU each.

The way we access these specific GPUs is by configuring openstack to only load the following GPU addresses for VM creations (when GPU is requested), below is the sample configuration from nova service from openstack for selecting specific GPUs:

```conf
# nova.conf
[pci]
device_spec = [{"address": "a3:00.0"}, {"address": "c3:00.0"}, {"address": "27:00.0"}, {"address": "44:00.0"}]
```

## Flavors

Flavors define the compute, memory, and storage capacity and attached PCI devices (GPU in this case) for creation of a VM.
We have defined a bunch of flavors for different use cases like GPU/CPU, Low/High Memory/cores runners. They can be
created via `openstack flavor` command. Example:

```bash
openstack flavor create --public gpu_4xlarge --id gpu_4xlarge --ram 65536 --disk 60 --vcpus 8
openstack flavor set gpu_4xlarge --property  "pci_passthrough:alias"="tesla-v100:1"
```

See [README.md](/README.md) for currently available flavors.

## Resource quotas

### Query current quotas

The resource quota(s) for OpenStack can be seen via the following command:

```bash
openstack quota show --default
```

### Update quotas

The resource quota(s) can be updated via `openstack quota set`. The example below is to update max instance count that can be spun up:

```
openstack quota set --class --instances 15 default
```

## OpenStack Services

Here is a list of core OpenStack services with brief summaries.

- Cinder: Block Storage service for providing volumes to Nova virtual machines
- Nova: responsible for provisioning of compute instances
- Horizon: Web based user interface to OpenStack services
- Keystone: Identity and authentication for all OpenStack services.
- Glance: Compute image repository
- Neutron: responsible for provisioning the virtual or physical networks that compute instances connect to on boot.
- Placement: responsible for tracking inventory of resources available in a cloud and assisting in choosing which

More about these can be read on OpenStack documentation.
