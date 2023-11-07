set -ex

DIB_RELEASE=jammy
DIB_CLOUD_IMAGES=https://cloud-images.ubuntu.com/jammy/20230914/
DIB_MODPROBE_BLACKLIST=”nouveau”
DIB_CLOUD_INIT_DATASOURCES="OpenStack"
DIB_DHCP_TIMEOUT=30
DIB_NO_TMPFS=1

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

echo "Starting Disk Image builder"
disk-image-create \
  ${IMAGE_YAML:-cpu-image.yaml}
  --no-tmpfs \
  -o "${OUTPUT_IMAGE}"
echo "Starting Disk Image Finished"
