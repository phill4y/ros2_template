#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"
ENV_TEMPLATE_PATH="${PARENT_DIR}/template.env"
LOCAL_ENV_PATH="${PARENT_DIR}/.env"

# Detect OS
OS_TYPE="$(uname -s)"
if [[ "${OS_TYPE}" == "Darwin" ]]; then
    SED_CMD='sed -i "" -e'
    echo "macOS detected"
else
    SED_CMD='sed -i'
    echo "Linux detected"
fi

# Load environment variables from the .env file
if [[ -f "${ENV_TEMPLATE_PATH}" ]]; then
    # shellcheck disable=SC1090
    source "${ENV_TEMPLATE_PATH}"
else
    echo "${ENV_TEMPLATE_PATH} not found"
    exit 1
fi

# Check if .env file already exists, if not create it
if [[ -f "${LOCAL_ENV_PATH}" ]]; then
    echo "Local env file already exists"
else
    cp "${ENV_TEMPLATE_PATH}" "${LOCAL_ENV_PATH}"
    echo "Local env file created"
fi

# Check if the NVIDIA runtime is available
# shellcheck disable=SC2312
if ! docker info | grep -q 'nvidia'; then
    echo "NVIDIA runtime is not available"

    if [[ -f "${LOCAL_ENV_PATH}" ]]; then
        # Check if CONTAINER_RUNTIME is set to nvidia
        if grep -q '^CONTAINER_RUNTIME=nvidia' "${LOCAL_ENV_PATH}"; then
            # Replace 'nvidia' with an empty value
            ${SED_CMD} 's/^CONTAINER_RUNTIME=nvidia/CONTAINER_RUNTIME=/' "${LOCAL_ENV_PATH}"
            echo "CONTAINER_RUNTIME has been updated to empty in ${LOCAL_ENV_PATH}"
        else
            echo "CONTAINER_RUNTIME is not set to nvidia in ${LOCAL_ENV_PATH}"
        fi
    else
        echo "${LOCAL_ENV_PATH} not found"
    fi
else
    echo "NVIDIA runtime is available. No changes made."
fi

# Detect platform
ARCH=$(uname -m)
# Map architecture to Docker platform naming convention
case "${ARCH}" in
    x86_64) PLATFORM="amd64" ;;
    aarch64 | arm64) PLATFORM="arm64" ;;
    *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

# Update PLATFORM in the .env file
${SED_CMD} "s/^PLATFORM=.*/PLATFORM=${PLATFORM}/" "${LOCAL_ENV_PATH}"

# Verify that SELECTED_DEVCONTAINER is set
if [[ -z "${SELECTED_DEVCONTAINER}" ]]; then
    echo "SELECTED_DEVCONTAINER is not set in ${LOCAL_ENV_PATH}"
    exit 1
fi

# Execute xhost command if PLATFORM is not arm64 and not macOS
if [[ "${PLATFORM}" != "arm64" && "${OS_TYPE}" != "Darwin" ]]; then
    if command -v xhost &>/dev/null; then
        xhost +local:root || true
    else
        echo "xhost command not found, skipping xhost setup."
    fi
fi
