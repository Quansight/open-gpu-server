# open-gpu-server

This repository provides information about the OpenStack instance Quansight and MetroStar are providing to conda-forge and other communities.

## Access

The main intent of this service is to provide GPU CI to those conda-forge feedstocks that require it. Feedstocks must request access via [`conda-forge/admin-requests`](https://github.com/conda-forge/admin-requests), as instructed in the README there.

Note that by applying and using the service, users must agree to the [Terms of Service](./TOS.md).

## Base configuration

- Model: AMD EPYC 7352 24-Core Processor
- Architecture: `x86_64`, 32-bit, 64-bit
- 48 Cores
- ~500 GB Memory
- 6x NVIDIA Tesla V100

## Available runners

The server can spin up VMs with the following configurations:

### GPU runners

| Name          | vCPUs | RAM  | Disk  | GPUs                 |
| ------------  | ----- | ---- | ----- | -------------------- |
| `gpu_tiny`    | 4     | 2GB  | 20GB  | 1x NVIDIA Tesla V100 |
| `gpu_medium`  | 4     | 8GB  | 50GB  | 1x NVIDIA Tesla V100 |
| `gpu_large`   | 4     | 12GB | 60GB  | 1x NVIDIA Tesla V100 |
| `gpu_xlarge`  | 8     | 16GB | 60GB  | 1x NVIDIA Tesla V100 |
| `gpu_2xlarge` | 8     | 32GB | 60GB  | 1x NVIDIA Tesla V100 |
| `gpu_4xlarge` | 8     | 64GB | 60GB  | 1x NVIDIA Tesla V100 |

These runners use the `ubuntu-2204-nvidia-20230914` image.

### CPU runners

| Name         | vCPUs | RAM  | Disk   |
| ------------ | ----- | ---- | ------ |
| `ci_medium`  | 4     | 8GB  | 60GB   |
| `ci_large`   | 4     | 12GB | 60GB   |

These runners use the `ubuntu-2204-20231018` image.

### Software

These runners run ISOs derived from Ubuntu 22.04. Images are built with the instructions provided in the [`images`](./images) folder.

## Limitations

* Concurrency depends on available resources. Only 4 GPUs can be exposed to the VMs at a time; expect queues. This is not per repository, but a server-wide limitation. See [docs/setup.md](/docs/setup.md) for details.
* We have not yet implemented a time limit per job. Please be mindful of this and try to keep your jobs as short as possible. This might change in the future.

## Support

This service is provided as is, with no guarantees of uptime or support. If you have any questions, please open an issue in this repository and we'll try our best.
