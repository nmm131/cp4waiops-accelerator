#!/bin/sh

# Agile Service Manager (ASM) OpenShift Credentials
PASSWORD="$(oc get secret aiops-topology-asm-credentials -n cp4waiops -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}' | grep "password" | cut -d ":" -f2 | xargs)"
USERNAME="$(oc get secret aiops-topology-asm-credentials -n cp4waiops -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}' | grep "username" | cut -d ":" -f2 | xargs)"
X_TENANT_ID='cfd95b7e-3bc7-4006-a4a8-a73a79c71255'

# OpenShift host and default Swagger URLs
NAMESPACE='cp4waiops'
PROXY_DOMAIN=$(oc get ingress.config cluster -o jsonpath='{.spec.domain}')
KUBERNETES_OBSERVER_BASE_URL="https://asm-svt-$NAMESPACE.$PROXY_DOMAIN/1.0/kubernetes-observer"
# FILE_OBSERVER="https://asm-svt-$NAMESPACE.$PROXY_DOMAIN/1.0/file-observer"
# REST_OBSERVER="https://asm-svt-$NAMESPACE.$PROXY_DOMAIN/1.0/rest-observer"

# # Return the status of the kubernetes observer
curl -k -X GET \
"$KUBERNETES_OBSERVER_BASE_URL/healthcheck" \
| jq

# # Get kubernetes observer jobs
curl -k -X GET \
-H  "Content-Type: application/json" \
-H  "Accept: application/json" \
-H "X-TenantID: $X_TENANT_ID" \
--user "$USERNAME:$PASSWORD" \
"$KUBERNETES_OBSERVER_BASE_URL/jobs?_limit=100"

echo "\n\n

"

# # Get kubernetes observer job
# curl -k -X GET \
# -H  "Content-Type: application/json" \
# -H  "Accept: application/json" \
# -H "X-TenantID: $X_TENANT_ID" \
# --user "$USERNAME:$PASSWORD" \
# "$KUBERNETES_OBSERVER_BASE_URL/jobs?_limit=100"

# Create a kubernetes observer local job
curl -k -X POST \
-H  "Content-Type: application/json" \
-H  "Accept: application/json" \
-H "X-TenantID: $X_TENANT_ID" \
--user "$USERNAME:$PASSWORD" \
-d '{"unique_id":"RobotShop","type":"string","description":"RobotShop job description","parameters":{"data_center":"demo","namespace":"robot-shop","hide_terminated_pods":true,"namespaceGroupParameters":{"correlate":true}},"schedule":{"interval":0,"units":"Days","nextRunTime":0},"scheduleRequest":true}' \
"$KUBERNETES_OBSERVER_BASE_URL/jobs/local"