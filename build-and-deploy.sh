#!/bin/sh

# Build the container
docker build -t cp4waiops-accelerator:latest --label cp4waiops-accelerator-original -f ./config/Dockerfile .
docker image prune --force --filter='label=cp4waiops-accelerator-original'

# Remove the container
docker stop cp4waiops-accelerator
docker rm cp4waiops-accelerator

# Run the container
# docker run -it --name cp4waiops-accelerator --env-file ./config/.env cp4waiops-accelerator
docker run -i --name cp4waiops-accelerator cp4waiops-accelerator