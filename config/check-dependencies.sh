#!/bin/sh

# Exit script if any variable/command/pipe fails
set -euo pipefail

# Import variables
. ./config/config.sh

# TODO: Check if sh is installed

# Check if sed is installed
if [ ! -x "$(command -v "$SED")" ]
then
	printf "This script uses %s. To run the script, you must install %s:\nbrew install gnu-sed\n" "$SED" "$SED"
	exit 1
fi

# Check if the correct version of jq is installed
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