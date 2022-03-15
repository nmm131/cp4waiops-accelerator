#!/bin/sh

# # Check dependencies
# curl -sfL https://raw.github.ibm.com/CP4WAIOPS-Accelerator/cp4waiops-accelerator/main/config/check-dependencies.sh | sh -
# Check if the correct version of jq is installed
printf "Checking Dependencies"
if [ "$(printf "%s\n" "$(jq --version | grep -o '[0-9]\+[.]*[0-9]*')>1.4" | bc)" -eq "0" ]
then
	printf "This script uses jq. To run the script, you must install jq\n"
	exit 1
fi

# Check if the correct version of OpenShift CLI is installed
OC_CLIENT_VERSION=$(oc version --client | grep -o '[0-9]\+[.]*[0-9]*' | head -n 1)
if [ "$(printf "%s\n" "$OC_CLIENT_VERSION>4.5" | bc)" -eq "0" ]
then
	oc version
	printf "This script uses oc. To run the script, you must install OpenShift Client Version >=4.6\n"
	exit 1
fi

# Check if logged into OpenShift Cluster
if [ ! "$(oc status 2> /dev/null)" ]
then
	printf "This script requires you to be logged in to an OpenShift cluster. To run the script, you must log in to your OpenShift cluster:\noc login\n"
	exit 1
fi

# Check if the correct version of Red Hat OpenShift Container Platform is installed
OC_SERVER_VERSION=$(oc version -o yaml | grep openshiftVersion | grep -o '[0-9]\+[.]*[0-9]*' | head -n 1)
if [ "$(printf "%s\n" "$OC_SERVER_VERSION>4.5" | bc)" -eq "0" ]
then
	oc version
	printf "This script uses oc. To run the script, you must install OpenShift Server Version >=4.6\n"
	exit 1
fi

# # Import variables
# curl -s https://raw.github.ibm.com/CP4WAIOPS-Accelerator/cp4waiops-accelerator/main/config/config.sh | sh -
# TODO: Read input 

# Initialize variables for reading
# Make sure secret variables are cleared and not exported
IFS=
REPLY='continue'
REPLY2='continue'
NAMESPACE=cp4waiops
ENTITLEMENT=ibm-entitlement-key
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
    read -r REGISTRY_SERVER_ADDRESS </dev/tty
    printf "\nInput your container image registry username: "
    read -r USERNAME </dev/tty
    printf "\nInput your container image registry password: [input is hidden] "
    read -rs PASSWORD </dev/tty
    printf "\n\nInput your container image registry email: [optional] "
    read -r EMAIL </dev/tty
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

oc get namespace | grep "$NAMESPACE" | grep -q "Active" || oc create namespace "$NAMESPACE" || :

if oc get secret/"$ENTITLEMENT" -n "$NAMESPACE" >/dev/null 2>&1; then
    printf "IBM Entitlement Key Secret already exists, add your IBM Entitlement Key to the Global Image Pull Secret? N/y: "
    read -r REPLY2 </dev/tty
fi
if [ "$REPLY2" = "Y" ] || [ "$REPLY2" = "y" ]; then
    # Ask user for entitlement key and e-mail
    printf "\nInput your IBM Entitled Registry entitlement key: [input is hidden] "
    read -rs ENTITLEMENT_KEY </dev/tty
    printf "\n\nInput your IBM Entitled Registry email: [optional] "
    read -r OCP_LOGIN_CREDENTIALS </dev/tty
    printf "\n"
    # Add an entitlement key
    oc create secret docker-registry "$ENTITLEMENT" \
        --docker-username=cp --docker-password="$ENTITLEMENT_KEY" \
        --docker-server=cp.icr.io \
        --namespace="$NAMESPACE" \
        --docker-email="$OCP_LOGIN_CREDENTIALS"
elif [ "$REPLY" = "N" ] || [ "$REPLY" = "n" ] || [ -z "$REPLY" ]; then
    echo "Update IBM Entitlement Key skipped"
fi

oc apply -f https://raw.github.ibm.com/CP4WAIOPS-Accelerator/cp4waiops-accelerator/main/config/cp4waiops-accelerator.yaml
