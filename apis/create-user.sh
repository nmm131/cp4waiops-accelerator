#!/bin/sh
set -x
NAMESPACE=cp4waiops
PROXY_DOMAIN=$(oc get ingress.config cluster -o jsonpath='{.spec.domain}')
CPD_CLUSTER_HOST="cpd-$NAMESPACE.$PROXY_DOMAIN"
PORT='443'
ADMIN_USERNAME='admin'
ADMIN_PASSWORD="$(oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d)"
TOKEN="$(curl -k -X POST -H "cache-control: no-cache" -H "Content-Type: application/json" -d "{\"username\":\"$ADMIN_USERNAME\",\"password\":\"$ADMIN_PASSWORD\"}" "https://$CPD_CLUSTER_HOST:$PORT/icp4d-api/v1/authorize" | jq | grep token | tr -d '"' | cut -d ':' -f2)"
USERNAME='guest'
PASSWORD='guest_pass'
DISPLAY_NAME='guest'

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