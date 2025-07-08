#!/bin/bash
set -e

# Get the group ID of the Docker socket
DOCKER_GROUP_ID=$(stat -c '%g' "/var/run/docker.sock")
DOCKER_GROUP_NAME="docker-host"
echo "Docker socket group ID: ${DOCKER_GROUP_ID}"

# Check if a group with this GID already exists
#shellcheck disable=SC2312
EXISTING_GROUP=$(getent group | awk -F: -v gid="${DOCKER_GROUP_ID}" '$3 == gid { print $1 }')

if [[ -n "${EXISTING_GROUP}" ]]; then
    echo "Group with GID ${DOCKER_GROUP_ID} already exists: ${EXISTING_GROUP}"
    DOCKER_GROUP_NAME="${EXISTING_GROUP}"
else
    echo "Creating Docker group '${DOCKER_GROUP_NAME}' with GID ${DOCKER_GROUP_ID}..."
    sudo groupadd -g "${DOCKER_GROUP_ID}" "${DOCKER_GROUP_NAME}"
fi

# Add the user to the Docker group
echo "Adding user '${USER}' to the Docker group '${DOCKER_GROUP_NAME}'..."
if id "${USER}" &>/dev/null; then
    sudo usermod -aG "${DOCKER_GROUP_NAME}" "${USER}"
else
    echo "User '${USER}' does not exist. Creating user..."
    sudo useradd -m -s /bin/bash "${USER}"
    sudo usermod -aG "${DOCKER_GROUP_NAME}" "${USER}"
fi

# Configure multicast on loopback interface
echo "Configuring multicast on loopback interface..."
sudo ip link set dev lo multicast on || true
sudo ip route add 224.0.0.0/4 dev lo || true

# Check if .pre-commit-config.yaml exists and install hooks
# shellcheck disable=SC2154
if [[ -f "/ws/.pre-commit-config.yaml" ]]; then
    echo "Setting up pre-commit hooks..."
    pre-commit install
    pre-commit install-hooks
else
    echo "No .pre-commit-config.yaml found. Skipping pre-commit setup."
fi

# git lfs install
# git lfs pull

# Run zsh if no command is passed to container
if [[ -z "$1" ]]; then
    exec zsh
else
    exec "$@"
fi
