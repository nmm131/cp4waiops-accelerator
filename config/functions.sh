#!/bin/sh

# Exit script if any variable/command/pipe fails
set -euo pipefail

wait_for_namespace() {
	until oc get namespace | grep "$NAMESPACE" | grep -q "Active"
	do
		printf "\tWaiting for '%s' namespace\n" "$NAMESPACE"
		sleep 3
	done
    printf "\n"
}