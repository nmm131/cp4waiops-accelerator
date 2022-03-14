#!/bin/sh

# Check dependencies
curl -sfL https://raw.github.ibm.com/CP4WAIOPS-Accelerator/cp4waiops-accelerator/main/config/check-dependencies.sh | sh -

# Import variables
curl -sfL https://raw.github.ibm.com/CP4WAIOPS-Accelerator/cp4waiops-accelerator/main/config/config.sh | sh -

# Initialize variables for reading
# Make sure secret variables are cleared and not exported
IFS=
REPLY='continue'
set +o allexport
unset -v REGISTRY_SERVER_ADDRESS
unset -v USERNAME
unset -v PASSWORD
unset -v EMAIL
unset -v ENTITLEMENT_KEY
unset -v OCP_LOGIN_CREDENTIALS


printf "Global Image Pull Secret already exists, add your container image registry credentials (e.g., Quay, Docker) to the Global Image Pull Secret? N/y: "
read -r REPLY </dev/tty
if [ "$REPLY" = "Y" ] || [ "$REPLY" = "y" ]; then
    # Ask user for image pull secret credentials and e-mail
    printf "Input your container image registry server address: "
    read -r REGISTRY_SERVER_ADDRESS
    printf "\nInput your container image registry username: "
    read -r USERNAME
    printf "\nInput your container image registry password: [input is hidden] "
    read -rs PASSWORD
    printf "\n\nInput your container image registry email: [optional] "
    read -r EMAIL
    printf "\n"

    # Add credentials to global image pull secret
    oc extract secret/pull-secret -n openshift-config --keys=.dockerconfigjson --to=. --confirm
    AUTH=$(printf "%s" "$USERNAME:$PASSWORD" | base64)
    cat >./.dockerconfigjson_append <<EOF
    {"auths":{"$REGISTRY_SERVER_ADDRESS":{"username":"$USERNAME","password":"$PASSWORD","auth":"${AUTH}","email":"$EMAIL"}}}
EOF
    printf "%s" "$(jq -s '.[0] * .[1]' .dockerconfigjson .dockerconfigjson_append)" >./.dockerconfigjson
    oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson
    printf "" > .dockerconfigjson
    printf "" > .dockerconfigjson_append
    rm .dockerconfigjson .dockerconfigjson_append

elif [ "$REPLY" = "N" ] || [ "$REPLY" = "n" ] || [ -z "$REPLY" ]; then
    echo "Update Global Image Pull Secret skipped"
fi

REPLY='continue'
if oc get secret/"$ENTITLEMENT" -n "$NAMESPACE" >/dev/null 2>&1; then
    printf "IBM Entitlement Key Secret already exists, add your IBM Entitlement Key to the Global Image Pull Secret? N/y: "
    read -r REPLY </dev/tty
fi
if [ "$REPLY" = "Y" ] || [ "$REPLY" = "y" ]; then
    # Ask user for entitlement key and e-mail
    printf "\nInput your IBM Entitled Registry entitlement key: [input is hidden] "
    read -rs ENTITLEMENT_KEY
    printf "\n\nInput your IBM Entitled Registry email: [optional] "
    read -r OCP_LOGIN_CREDENTIALS
    printf "\n"
    # Add an entitlement key
    oc create secret docker-registry "$ENTITLEMENT" \
        --docker-username=cp --docker-password="$ENTITLEMENT_KEY" \
        --docker-server=cp.icr.io \
        --namespace="$NAMESPACE" \
        --docker-email="$OCP_LOGIN_CREDENTIALS"
elif [ "$REPLY" = "N" ] || [ "$REPLY" = "n" ] || [ -z "$REPLY" ]; then
    echo "Update IBM Entitlement Key skipped"
    exit 0
fi

oc apply -f https://raw.github.ibm.com/CP4WAIOPS-Accelerator/cp4waiops-accelerator/main/config/cp4waiops-accelerator.yaml
