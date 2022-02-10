#!/bin/sh
set -x
CPD_CLUSTER_HOST='https://cpd-cp4waiops.itzroks-662001vtd7-t0gdwo-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-gb.containers.appdomain.cloud'
PORT='443'
ADMIN_USERNAME=''
ADMIN_PASSWORD="$(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d)"
TOKEN="$(curl -k -X POST -H "cache-control: no-cache" -H "Content-Type: application/json" -d "{\"username\":\"$ADMIN_USERNAME\",\"password\":\"$ADMIN_PASSWORD\"}" "https://$CPD_CLUSTER_HOST:$PORT/icp4d-api/v1/authorize" | jq | grep token | tr -d '"' | cut -d ':' -f2)"
USERNAME=''
PASSWORD=''
DISPLAY_NAME=''

# zen_administrator_role permissions
# "administrator",
# "can_provision",
# "manage_catalog",
# "create_project",
# "create_space"
USER_ROLES='zen_administrator_role'
EMAIL='example@example.com'


# # Get all users
# curl -k -X GET \
# -H "Authorization: Bearer $TOKEN" \
# -H "cache-control: no-cache" \
# "https://$CPD_CLUSTER_HOST:$PORT/icp4d-api/v1/users" \
# jq

# # Get all roles
# curl -k -X GET \
# -H "Authorization: Bearer $TOKEN" \
# -H "cache-control: no-cache" \
# "https://$CPD_CLUSTER_HOST:$PORT/icp4d-api/v1/roles" \
# jq

# Create a user
curl -k -X POST \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $TOKEN" \
-H "cache-control: no-cache" \
-d "{\"user_name\":\"$USERNAME\",\"password\":\"$PASSWORD\",\"displayName\":\"$DISPLAY_NAME\",\"user_roles\":[\"$USER_ROLES\"],\"email\":\"$EMAIL\"}" \
"https://$CPD_CLUSTER_HOST:$PORT/icp4d-api/v1/users"