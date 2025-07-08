#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ENV_TEMPLATE_PATH="${SCRIPT_DIR}/template.env"
LOCAL_ENV_PATH="${SCRIPT_DIR}/.env"

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

# Detect platform
ARCH=$(uname -m)
# Map architecture to Docker platform naming convention
case "${ARCH}" in
    x86_64) PLATFORM="amd64" ;;
    aarch64 | arm64) PLATFORM="arm64" ;;
    arm64 | arm64) PLATFORM="arm64" ;;
    *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

# Detect OS
OS_TYPE="$(uname -s)"
if [[ "${OS_TYPE}" == "Darwin" ]]; then
    SED_CMD='sed -i "" -e'
    echo "macOS detected"
else
    SED_CMD='sed -i'
    echo "Linux detected"
fi

# Update PLATFORM in the .env file
${SED_CMD} "s/^PLATFORM=.*/PLATFORM=${PLATFORM}/" "${LOCAL_ENV_PATH}"

export PLATFORM

echo "Building devcontainer base image for platform: ${PLATFORM}"

#shellcheck disable=SC2086
docker compose -f "${SCRIPT_DIR}"/docker-compose.base.yml build devcontainer-jazzy
