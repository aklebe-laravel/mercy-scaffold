#!/bin/bash
set -euo pipefail

# ==============================================================================
# 1. Guard Clause: Ensure valid directory scope
# ==============================================================================
if [ ! -f "compose.yaml" ] && [ ! -f "compose.yml" ] && [ ! -f "docker-compose.yaml" ] && [ ! -f "docker-compose.yml" ]; then
    echo "ERROR: No docker compose file found. Aborting to protect system." >&2
    exit 1
fi

# Confirmation
read -p "Destroy the whole project files, dockers and images? (y/n): " antwort

# Abort if the answer is NOT "y" or "Y"
if [[ ! "$antwort" =~ ^[Yy]$ ]]; then
    echo "Confirmation declined. Aborted."
    exit 0
fi

# ==============================================================================
# 2. Extract context metadata
# ==============================================================================
CURRENT_PROJECT=$(docker compose config --format json 2>/dev/null | grep -E '"name":' | head -n 1 | awk -F'"' '{print $4}' || echo "")

if [ -z "$CURRENT_PROJECT" ]; then
    CURRENT_PROJECT=$(basename "$PWD" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
fi

# Prevent system directory suicide
if [ -z "$CURRENT_PROJECT" ] || [ "$CURRENT_PROJECT" = "html" ] || [ "$CURRENT_PROJECT" = "var" ] || [ "$CURRENT_PROJECT" = "root" ]; then
    echo "ERROR: Dangerous project name context ('${CURRENT_PROJECT}'). Aborting." >&2
    exit 1
fi

echo "=== RADICAL PURGE: Destroying EVERYTHING for ${CURRENT_PROJECT} ==="

# Without .env the compose file cannot be resolved (variables like REVERB_HOST are missing) and the
# install never got to start containers (the .env is created before the containers). Only files are removed then.
if [ -f ".env" ]; then
    # ==========================================================================
    # 3. Destroy Containers, Networks and persistent database Volumes
    # ==========================================================================
    echo "Dropping infrastructure layer, isolated networks, and core storage volumes..."
    # --volumes: Wipes the MariaDB volume, killing all stalled job queues instantly
    # --rmi all: Erases ALL images used by this compose file (local builds + pulled tags)
    # --remove-orphans: Cleans up any detached service artifacts
    docker compose down --volumes --rmi all --remove-orphans \
        || echo "WARNING: 'docker compose down' failed, check 'docker ps -a' for leftovers of ${CURRENT_PROJECT}." >&2

    # ==========================================================================
    # 4. Enforce strict Docker Engine Prune targeted ONLY at this project
    # ==========================================================================
    echo "Targeting dangling image layers and build caches for this project context..."
    # Purge every image layer that carries this specific compose project label metadata
    docker images --filter "label=com.docker.compose.project=${CURRENT_PROJECT}" -q | xargs -r docker rmi -f || true

    # Force cache eviction for building layers tied to this project
    docker builder prune --filter "until=1h" -f || true

    # Force sync to disk to tell Proxmox storage layers that space is ready to be reclaimed
    sync
    sleep 2
else
    echo "No .env found: no containers were started from this folder, skipping the docker cleanup."
fi

# ==============================================================================
# 5. Clean local installation files completely (Preserving ONLY this script)
# ==============================================================================
echo "Erasing local file base directory contents..."
SCRIPT_NAME=$(basename "$0")
find . -mindepth 1 ! -name "$SCRIPT_NAME" -delete

echo "=== WIPE COMPLETE: ${CURRENT_PROJECT} is completely vanished. ==="
