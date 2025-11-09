# VM Images

Builds Ubuntu 24.04 images for OpenStack with Docker and NVIDIA drivers (GPU only).

## Quick Start

From the repo root, run:

```bash
# Build CPU image (can run anywhere)
make build-cpu

# Build GPU image (MUST run on GPU server)
make build-gpu

# Upload to OpenStack
make upload-cpu
make upload-gpu
```

## Requirements

- `uv` package manager ([install here](https://docs.astral.sh/uv/))
- Linux (builds won't work on Mac)
- Root access (diskimage-builder needs it)
- OpenStack credentials from `/etc/kolla/admin-openrc.sh` on GPU server (for uploads only)

## Build Directory

By default images build to `/tmp/vm-images-build-{timestamp}`. Override with:

```bash
make build-cpu BUILD_DIR=/path/to/build
```

## Custom UV Path

If uv isn't in your PATH:

```bash
make build-cpu UV=/path/to/uv
```

## Automated Builds

GitHub Actions workflow (`.github/workflows/build-images-ssh.yml`) can be triggered manually via workflow_dispatch.

The workflow SSHs into the GPU server to run both CPU and GPU builds. Uploads to OpenStack only happen on `main` branch. GPU images require actual GPU hardware - they'll fail without it.

## Image Contents

**Both images:**
- Ubuntu 24.04 (Noble)
- Docker
- Node.js
- cloud-init

**GPU images only:**
- NVIDIA drivers
- CUDA

## Manual Upload

If you need to upload manually:

```bash
source /etc/kolla/admin-openrc.sh
openstack image create my-image-name \
  --public --disk-format qcow2 \
  --container-format bare \
  --file path/to/image.qcow2
```

## Cleanup

```bash
make clean BUILD_DIR=/path/to/build
```
