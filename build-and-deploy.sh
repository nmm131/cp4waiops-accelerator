#!/bin/sh

TAG='latest'
LABEL='cp4waiops-accelerator-original'
IMAGE_NAME='cp4waiops-accelerator'
QUAY_USER='nate_malone_ibm'

# Build the container
docker build -t "$IMAGE_NAME":"$TAG" --label "$LABEL" -f ./config/Dockerfile .
docker image prune --force --filter="label=$LABEL"

# # Remove the container
# docker stop "$IMAGE_NAME"
# docker rm "$IMAGE_NAME"

# # Run the container
# # docker run -it --name "$IMAGE_NAME" --env-file ./config/.env "$IMAGE_NAME"
# docker run -i --name "$IMAGE_NAME" "$IMAGE_NAME":"$TAG"

# Push the container image
docker tag "$IMAGE_NAME":$TAG quay.io/"$QUAY_USER"/"$IMAGE_NAME":$TAG
docker push quay.io/"$QUAY_USER"/"$IMAGE_NAME":$TAG

# Deploy the container
#oc apply -f ./config/cp4waiops-accelerator.yaml
./config/setup.sh