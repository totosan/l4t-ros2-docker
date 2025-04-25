#!/bin/bash

# Build the optimized multi-stage image

#build the base image with invalidation of cache and save the image
#docker buildx build --target build --no-cache-filter build --platform linux/arm64 --build-arg UID=1000 --build-arg GID=1000 -f ./humble/Dockerfile -t l4t-ros2:humble-slim-build . --progress=plain

#build with stage cache and save the image
#docker buildx build --target build --platform linux/arm64 --build-arg UID=1000 --build-arg GID=1000 -f ./humble/Dockerfile -t l4t-ros2:humble-slim-build . --progress=plain

# Build the final image and save the image
#docker buildx build --platform linux/arm64 --build-arg UID=1000 --build-arg GID=1000 ./humble/Dockerfile -t l4t-ros2-build:humble .
docker buildx build --target runtime --platform linux/arm64 --build-arg UID=1000 --build-arg GID=1000 -f ./humble/Dockerfile -t l4t-ros2:humble-slim . #--progress=plain
