#!/bin/bash

if [[ $(uname) == Darwin ]]; then
  echo "This script can only run on Linux"
  exit 1
fi

set -ex

DIB_RELEASE=noble
DIB_CLOUD_IMAGES=https://cloud-images.ubuntu.com/noble/20251026/
DIB_MODPROBE_BLACKLIST=”nouveau”
DIB_CLOUD_INIT_DATASOURCES="OpenStack"
DIB_DHCP_TIMEOUT=30
DIB_NO_TMPFS=1
ELEMENTS_PATH="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/elements"
export ELEMENTS_PATH

if [[ -z "${LOG_TO_FILE}" ]]; then 
  LOG_TO_FILE="--logfile dib.log"
fi
if [[ -z "${IMAGE_YAML}" ]]; then 
  IMAGE_YAML="cpu-image.yaml"
fi
if [[ -z "${OUTPUT_IMAGE}" ]]; then 
  output_fn=$(basename -- "${IMAGE_YAML}")
  OUTPUT_IMAGE="${output_fn%.*}-$(date +%Y%m%d%H%M).qcow2"
fi

export TMP=$(pwd)
echo "Starting Disk Image builder"
sudo -E "$(which diskimage-builder)" "${IMAGE_YAML}" 
mv "${IMAGE_YAML%.*}.qcow2" "${OUTPUT_IMAGE}"
echo "Starting Disk Image Finished"
