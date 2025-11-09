.PHONY: help build-cpu build-gpu build-all upload-cpu upload-gpu upload-all clean show-image

# Default variables
BUILD_DIR ?= /tmp/vm-images-build-$(shell date +%s)
IMAGE_TYPE ?= cpu
TIMESTAMP := $(shell date +%Y%m%d-%H%M%S)
IMAGE_NAME := ubuntu-2404-$(IMAGE_TYPE)-$(TIMESTAMP)

# Path configuration
REPO_DIR := $(shell pwd)
VM_IMAGES_DIR := $(REPO_DIR)/vm-images
OPENSTACK_RC ?= /etc/kolla/admin-openrc.sh
CONDA_BASE ?= /opt/stack/miniconda3
CONDA_ENV ?= kolla

help:
	@echo "VM Image Build Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  build-cpu          - Build CPU image"
	@echo "  build-gpu          - Build GPU image"
	@echo "  build-all          - Build both CPU and GPU images"
	@echo "  upload-cpu         - Upload CPU image to OpenStack"
	@echo "  upload-gpu         - Upload GPU image to OpenStack"
	@echo "  upload-all         - Upload both images to OpenStack"
	@echo "  show-image         - Show built image information"
	@echo "  clean              - Clean up build directory"
	@echo ""
	@echo "Variables:"
	@echo "  BUILD_DIR=$(BUILD_DIR)"
	@echo "  IMAGE_TYPE=$(IMAGE_TYPE)"
	@echo "  IMAGE_NAME=$(IMAGE_NAME)"

build-cpu:
	@$(MAKE) _build IMAGE_TYPE=cpu

build-gpu:
	@$(MAKE) _build IMAGE_TYPE=gpu

build-all:
	@$(MAKE) build-cpu
	@$(MAKE) build-gpu

_build:
	@echo "======================================"
	@echo "Building $(IMAGE_TYPE) image: $(IMAGE_NAME)"
	@echo "======================================"
	mkdir -p $(BUILD_DIR)-$(IMAGE_TYPE)
	cp -r $(VM_IMAGES_DIR)/* $(BUILD_DIR)-$(IMAGE_TYPE)/
	cd $(BUILD_DIR)-$(IMAGE_TYPE) && \
		sed -i 's/imagename: $(IMAGE_TYPE)-image.qcow2/imagename: $(IMAGE_NAME).qcow2/' $(IMAGE_TYPE)-image.yaml
	cd $(BUILD_DIR)-$(IMAGE_TYPE) && \
		IMAGE_YAML=$(IMAGE_TYPE)-image.yaml bash build-image.sh
	@echo ""
	@$(MAKE) show-image IMAGE_TYPE=$(IMAGE_TYPE) BUILD_DIR=$(BUILD_DIR)

show-image:
	@echo "======================================"
	@echo "Built Image Information"
	@echo "======================================"
	@cd $(BUILD_DIR)-$(IMAGE_TYPE) && \
		IMAGE_FILE=$$(ls -1 *.qcow2 2>/dev/null | head -1) && \
		if [ -n "$$IMAGE_FILE" ]; then \
			echo "Image Path: $(BUILD_DIR)-$(IMAGE_TYPE)/$$IMAGE_FILE"; \
			echo "Image Size: $$(ls -lh $$IMAGE_FILE | awk '{print $$5}')"; \
			echo "Full Details:"; \
			ls -lh $$IMAGE_FILE; \
			echo ""; \
			if command -v qemu-img &> /dev/null; then \
				echo "QEMU Image Info:"; \
				qemu-img info $$IMAGE_FILE; \
			fi; \
		else \
			echo "No .qcow2 image file found!"; \
		fi
	@echo "======================================"

upload-cpu:
	@$(MAKE) _upload IMAGE_TYPE=cpu

upload-gpu:
	@$(MAKE) _upload IMAGE_TYPE=gpu

upload-all:
	@$(MAKE) upload-cpu
	@$(MAKE) upload-gpu

_upload:
	@echo "======================================"
	@echo "Uploading $(IMAGE_TYPE) image to OpenStack"
	@echo "======================================"
	@cd $(BUILD_DIR)-$(IMAGE_TYPE) && \
		source $(OPENSTACK_RC) && \
		source $(CONDA_BASE)/bin/activate && \
		conda activate $(CONDA_ENV) && \
		IMAGE_FILE=$$(ls -1 *.qcow2 2>/dev/null | head -1) && \
		IMAGE_BASE=$$(basename $$IMAGE_FILE .qcow2) && \
		echo "Uploading $$IMAGE_FILE..." && \
		openstack image create $$IMAGE_BASE \
			--public --disk-format qcow2 \
			--container-format bare \
			--file $$IMAGE_FILE && \
		echo "Image uploaded successfully!" && \
		openstack image show $$IMAGE_BASE

clean:
	@echo "Cleaning up build directories..."
	@if [ -d "$(BUILD_DIR)-cpu" ]; then sudo rm -rf $(BUILD_DIR)-cpu; fi
	@if [ -d "$(BUILD_DIR)-gpu" ]; then sudo rm -rf $(BUILD_DIR)-gpu; fi
	@echo "Cleanup complete"
