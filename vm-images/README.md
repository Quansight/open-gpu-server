# VM Images for OpenStack

Creates Ubuntu VM Images with following things installed:

- Nvidia drivers (GPU images only)
- Docker

The created image is uploaded to a GCS bucket, which is then retrieved by a self-hosted GHA runner running on our OpenStack instance.

## GHA workflows

These should automate the creation of the images:

- `.github/workflows/build-vm-images.yml` - Github Action to build the image
- `.github/workflows/openstack.yml` - Github Action to upload the VM image to OpenStack

## Building manually

1. Install `diskimage-builder` manually via `pip install -r requirements.txt`. A virtual environment is advised.
2. Run `scripts/build-image.sh` to build the image. This will create a `.qcow2` file. 
    - Export `$IMAGE_YAML` to choose a different image to build (e.g. `cpu-image.yaml`, `gpu-image.yaml`).
    - Export `$OUTPUT_IMAGE` to change the qcow2 output filename.

## Add Image to OpenStack

```bash
openstack image create ubuntu-2204-nvidia-docker \
  --public --disk-format qcow2 \
  --container-format bare \
  --file <created-image>.qcow2
```
