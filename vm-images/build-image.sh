#!/bin/bash

if [[ $(uname) == Darwin ]]; then
  echo "This script can only run on Linux"
  exit 1
fi

set -ex

export DIB_RELEASE=noble
export DIB_CLOUD_IMAGES=https://cloud-images.ubuntu.com/noble/20251026/
export DIB_MODPROBE_BLACKLIST="nouveau"
export DIB_CLOUD_INIT_DATASOURCES="OpenStack"
export DIB_DHCP_TIMEOUT=30
export DIB_LOCAL_IMAGE=/opt/stack/.cache/image-create/noble-server-cloudimg-amd64.squashfs
export DIB_NO_TMPFS=1
ELEMENTS_PATH="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/elements"
export ELEMENTS_PATH

if [[ -z "${IMAGE_YAML}" ]]; then 
  IMAGE_YAML="cpu-image.yaml"
fi

export TMP=$(pwd)
export COLUMNS=${COLUMNS:-200}
export TERM=${TERM:-xterm}

UV=${UV:-uv}

echo "Starting Disk Image builder"
echo "Using config: ${IMAGE_YAML}"

${UV} run diskimage-builder "${IMAGE_YAML}"

echo "Disk Image Build Finished"
