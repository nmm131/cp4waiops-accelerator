#!/bin/sh

# Build the container
docker build -t cp4waiops-accelerator:latest -f ./config/Dockerfile .

# Remove the container
docker rm cp4waiops-accelerator

# Run the container
docker run -it --name cp4waiops-accelerator --env-file ./config/.env cp4waiops-accelerator

docker exec -it ./10_install_ai_manager.sh -t $IBM_ENTITLEMENT_KEY bash