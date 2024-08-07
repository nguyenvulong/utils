#!/bin/bash

# Function to search for a hash in images

search_images() {
    echo "Searching in images..."
    IMAGE_IDS=$(docker images -q)  # Get all image IDs
    for IMAGE_ID in $IMAGE_IDS; do
        IMAGE_INFO=$(docker inspect --format='{{.RepoTags}} {{json .RootFS.Layers}}' $IMAGE_ID)
        IMAGE_NAME=$(echo $IMAGE_INFO | awk '{print $1}')  # Get the image name
        LAYERS=$(echo $IMAGE_INFO | cut -d' ' -f2-)  # Get the layers (everything after the image name)

        if echo "$LAYERS" | grep -q "$1"; then  # Check if the hash is in the layers
            echo "Image Name: $IMAGE_NAME"
            echo "Layers: $LAYERS"
        fi
    done
}

# Function to search for a hash in containers
search_containers() {
    echo "Searching in containers..."
    docker ps -a --no-trunc | grep "$1"
}

# Function to search for a hash in volumes
search_volumes() {
    echo "Searching in volumes..."
    VOLUME_NAMES=$(docker volume ls -q)
    for VOLUME in $VOLUME_NAMES; do
        if docker volume inspect $VOLUME | grep -q "$1"; then
            echo "Volume: $VOLUME"
            docker volume inspect $VOLUME
        fi
    done
}

# Main script
if [ $# -ne 1 ]; then
    echo "Usage: $0 <hash>"
    exit 1
fi

HASH=$1

echo "Searching for hash: $HASH"
echo "-----------------------------------"

# Search in images
search_images "$HASH"

echo "-----------------------------------"

# Search in containers
search_containers "$HASH"

echo "-----------------------------------"

# Search in volumes
search_volumes "$HASH"

echo "-----------------------------------"
echo "Search completed."
