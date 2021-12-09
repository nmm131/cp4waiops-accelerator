#!/bin/sh

# Build the container
docker build -t cp4waiops-accelerator:latest -f ./config/Dockerfile .

# Run the container
docker run -it --env-file ./config/.env cp4waiops-accelerator bash