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
if [[ -z "${OUTPUT_IMAGE}" ]]; then 
  OUTPUT_IMAGE="./"
fi
if [[ -z "${ELEMENTS}" ]]; then 
  OUTPUT_IMAGE="./"
fi

echo "Starting Disk Image builder"
# Each positional argument is an 'element' to add to the image
# Remove `cuda` for non GPU images
disk-image-create \
  vm \
  dhcp-all-interfaces \
  block-device-gpt \
  ubuntu \
  cuda -x \
  misc \
  --no-tmpfs \
  -o "$OUTPUT_IMAGE"
echo "Starting Disk Image Finished"
