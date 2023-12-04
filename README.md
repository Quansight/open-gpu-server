# open-gpu-server

This repository provides information about the OpenStack instance Quansight and MetroStar are providing to conda-forge and other communities.

## Access

The main intent of this service is to provide GPU CI to those conda-forge feedstocks that require it. To do so:

- **Feedstocks** must have access to the service. Refer to the [`conda-forge/admin-requests`](https://github.com/conda-forge/admin-requests) README.
- **Maintainers** you must read and agree to the [Terms of Service](./TOS.md). Your username must be listed in [`access/conda-forge-users.json`](./access/conda-forge-users.json). Please open a PR to add yourself to the list.

## Incidents

If you suspect the server is not operating as expected, please check:

- [Status page](https://open-gpu-server.openstatus.dev/)
- [Ongoing incidents](https://github.com/Quansight/open-gpu-server/issues?q=is%3Aopen+is%3Aissue+label%3Aincident%3Adegraded-performance%2Cincident%3Ainvestigating%2Cincident%3Amajor-outage+sort%3Aupdated-desc)

If you think there should be an open incident report but there's none, please open a new issue and tag [@Quansight/open-gpu-server](https://github.com/orgs/Quansight/teams/open-gpu-server) so the team can take a look. Thanks!

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
