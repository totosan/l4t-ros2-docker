#!/bin/bash

# Build the optimized multi-stage image

# Build the final image and save the image
docker buildx build --platform linux/arm64 --no-cache --build-arg UID=1000 --build-arg GID=1000 -f ./humble/Dockerfile -t l4t-ros2:humble-v2.4 .
