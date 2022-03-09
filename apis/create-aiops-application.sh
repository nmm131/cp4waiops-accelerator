#!/bin/sh
set -x

NAMESPACE='cp4waiops'
PROXY_DOMAIN=$(oc get ingress.config cluster -o jsonpath='{.spec.domain}')
URL="https://cpd-$NAMESPACE.$PROXY_DOMAIN"
APPLICATION_MANAGER_BASE_URL="https://asm-svt-$NAMESPACE.$PROXY_DOMAIN/1.0/topology"
API_KEY='7xaacbpJZPjrHaLeUGw09ugmgIQQvFtwtFgKwiXH'
PASSWORD="$(oc get secret aiops-topology-asm-credentials -n cp4waiops -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}' | grep "password" | cut -d ":" -f2 | xargs)"
USERNAME="$(oc get secret aiops-topology-asm-credentials -n cp4waiops -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}' | grep "username" | cut -d ":" -f2 | xargs)"
X_TENANT_ID='cfd95b7e-3bc7-4006-a4a8-a73a79c71255'



### resources
# curl -k -X POST \
# -H  "Content-Type: application/json" \
# -H  "Accept: application/json" \
# -H "X-TenantID: $X_TENANT_ID" \
# --user "$USERNAME:$PASSWORD" \
# -d @cp4waiops-assets/create-resource.json \
# "$APPLICATION_MANAGER_BASE_URL/resources" 

# ### groups
# curl -k -X POST \
# -H  "Content-Type: application/json" \
# -H  "Accept: application/json" \
# -H "X-TenantID: $X_TENANT_ID" \
# --user "$USERNAME:$PASSWORD" \
# -d @cp4waiops-assets/create-group.json \
# "$APPLICATION_MANAGER_BASE_URL/groups"

### app
curl -k -X POST \
-H  "Content-Type: application/json" \
-H  "Accept: application/json" \
-H "X-TenantID: $X_TENANT_ID" \
--user "$USERNAME:$PASSWORD" \
-d @cp4waiops-assets/create-application.json \
"$APPLICATION_MANAGER_BASE_URL/groups" 

# curl -k -X GET \
# -H  "Content-Type: application/json" \
# -H  "Accept: application/json" \
# -H "Authorization: ZenApiKey $API_KEY" \
# "$APPLICATION_MANAGER_BASE_URL/healthcheck" \
# | jq

# Agile Service Manager (ASM) OpenShift Credentials
# PASSWORD="$(oc get secret aiops-topology-asm-credentials -n cp4waiops -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}' | grep "password" | cut -d ":" -f2 | xargs)"
# USERNAME="$(oc get secret aiops-topology-asm-credentials -n cp4waiops -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}' | grep "username" | cut -d ":" -f2 | xargs)"
# X_TENANT_ID='cfd95b7e-3bc7-4006-a4a8-a73a79c71255'


# # OpenShift host and default Swagger URLs
# NAMESPACE='cp4waiops'
# PROXY_DOMAIN=$(oc get ingress.config cluster -o jsonpath='{.spec.domain}')
# URL="https://cpd-$NAMESPACE.$PROXY_DOMAIN"
# APPLICATION_MANAGER_BASE_URL="https://asm-svt-$NAMESPACE.$PROXY_DOMAIN/1.0/ui-api"
# BEARER_TOKEN=$(curl -k -X POST "$URL/icp4d-api/v1/authorize" -H 'cache-control: no-cache' -H 'content-type: application/json' -d "{\"username\":\"admin\",\"password\":\"ltCOpIWOJeX1sNboufEthbSYEbysWNYm\"}" | jq | grep token | tr -d '"' | cut -d ':' -f2)
# API_KEY=$(curl -k -X GET -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: Bearer $BEARER_TOKEN" -H "cache-control: no-cache" --user "admin:ltCOpIWOJeX1sNboufEthbSYEbysWNYm" "$URL/api/v1/usermgmt/v1/user/apiKey" | cut -d ":" -f2 | cut -d '"' -f2)
# PLATFORM_UI_TOKEN=$(curl -k -X POST https://$URL/icp4d-api/v1/authorize -H 'Content-Type: application/json' -d "{\"username\": \"$USERNAME\",\"api_key\": \"$API_KEY\"}")


# # Return the status of the ui-api
# curl -k -X GET \
# -H 
# "$APPLICATION_MANAGER_BASE_URL/healthcheck" \
# | jq

# # Get kubernetes observer jobs
# # curl -k -X GET \
# # -H  "Content-Type: application/json" \
# # -H  "Accept: application/json" \
# # -H "X-TenantID: $X_TENANT_ID" \
# # --user "$USERNAME:$PASSWORD" \
# # "$APPLICATION_MANAGER_BASE_URL/jobs?_limit=100"

# echo "\n\n

# "

# # # Get kubernetes observer job
# # curl -k -X GET \
# # -H  "Content-Type: application/json" \
# # -H  "Accept: application/json" \
# # -H "X-TenantID: $X_TENANT_ID" \
# # --user "$USERNAME:$PASSWORD" \
# # "$APPLICATION_MANAGER_BASE_URL/jobs?_limit=100"

# # Create a kubernetes observer local job
# # curl -k -X POST \
# # -H  "Content-Type: application/json" \
# # -H  "Accept: application/json" \
# # -H "X-TenantID: $X_TENANT_ID" \
# # --user "$USERNAME:$PASSWORD" \
# # -d '{"unique_id":"listenJob","type":"string","description":"job description","parameters":{"provider":"listenJob"},"schedule":{"interval":0,"units":"Days","nextRunTime":0},"scheduleRequest":true}' \
# # "$APPLICATION_MANAGER_BASE_URL/jobs/bulk_replace"

# curl -k -X GET \
# -H  "Content-Type: application/json" \
# -H  "Accept: application/json" \
# -H "Authorization: Bearer $BEARER_TOKEN" \
# -H "Authorization: ZenApiKey $API_KEY" \
# -d '{"name":"ai-app2","tags":[],"entityTypes":["waiopsApplication"],"correlatable":true,"iconId":"application","members":[{"_id":"fvuQ9HTITySn1gNUGhCewQ"}]}' \
# "$APPLICATION_MANAGER_BASE_URL/applications"
# # -d '{"unique_id":"RobotShop","type":"string","description":"RobotShop job description","parameters":{"data_center":"demo","namespace":"robot-shop","hide_terminated_pods":true,"namespaceGroupParameters":{"correlate":true}},"schedule":{"interval":0,"units":"Days","nextRunTime":0},"scheduleRequest":true}' \

# # curl -k -X GET \
# # -H  "Content-Type: application/json" \
# # -H  "Accept: application/json" \
# # -H "X-TenantID: $X_TENANT_ID" \
# # -H "X-UIQUERYID: createApplication" \
# # --user "$USERNAME:$PASSWORD" \
# # -d '{"name":"test01","tags":[],"entityTypes":["waiopsApplication"],"correlatable":true,"iconId":"application","members":[{"_id":"fvuQ9HTITySn1gNUGhCewQ"}]}' \
# # "https://cpd-cp4waiops.itzroks-662001vtd7-t0gdwo-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud/api/p/hdm_asm_ui_api/1.0/ui-api/applications"
