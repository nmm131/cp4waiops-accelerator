#!/bin/sh
set -e

oc project cp4waiops
PROXY_DOMAIN=$(oc get ingress.config cluster -o jsonpath='{.spec.domain}')
OPENSHIFT_PROJECT=$(oc project -q)

cat <<EOF | oc apply -f -
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: asm-svt-file-observer
  labels:
    app.kubernetes.io/name: file-observer
    app.kubernetes.io/instance: asm-svt
spec:
  host: asm-svt-${OPENSHIFT_PROJECT}.${PROXY_DOMAIN}
  path: /1.0/file-observer
  port:
    targetPort: https-file-observer-api
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: reencrypt
  to:
    kind: Service
    name: aiops-topology-file-observer
    weight: 100
  wildcardPolicy: None
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: asm-svt-kubernetes-observer
  labels:
    app.kubernetes.io/name: kubernetes-observer
    app.kubernetes.io/instance: asm-svt
spec:
  host: asm-svt-${OPENSHIFT_PROJECT}.${PROXY_DOMAIN}
  path: /1.0/kubernetes-observer
  port:
    targetPort: https-kubernetes-observer-api
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: reencrypt
  to:
    kind: Service
    name: aiops-topology-kubernetes-observer
    weight: 100
  wildcardPolicy: None
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: asm-svt-layout
  labels:
    app.kubernetes.io/name: layout
    app.kubernetes.io/instance: asm-svt
spec:
  host: asm-svt-${OPENSHIFT_PROJECT}.${PROXY_DOMAIN}
  path: /1.0/layout
  port:
    targetPort: https-layout-api
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: reencrypt
  to:
    kind: Service
    name: aiops-topology-layout
    weight: 100
  wildcardPolicy: None
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: asm-svt-merge
  labels:
    app.kubernetes.io/name: merge
    app.kubernetes.io/instance: asm-svt
spec:
  host: asm-svt-${OPENSHIFT_PROJECT}.${PROXY_DOMAIN}
  path: /1.0/merge
  port:
    targetPort: https-merge-api
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: reencrypt
  to:
    kind: Service
    name: aiops-topology-merge
    weight: 100
  wildcardPolicy: None
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: asm-svt-rest-observer
  labels:
    app.kubernetes.io/name: rest-observer
    app.kubernetes.io/instance: asm-svt
spec:
  host: asm-svt-${OPENSHIFT_PROJECT}.${PROXY_DOMAIN}
  path: /1.0/rest-observer
  port:
    targetPort: https-rest-observer-api
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: reencrypt
  to:
    kind: Service
    name: aiops-topology-rest-observer
    weight: 100
  wildcardPolicy: None
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: asm-svt-dns-observer
  labels:
    app.kubernetes.io/name: dns-observer
    app.kubernetes.io/instance: asm-svt
spec:
  host: asm-svt-${OPENSHIFT_PROJECT}.${PROXY_DOMAIN}
  path: /1.0/dns-observer
  port:
    targetPort: https-dns-observer-api
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: reencrypt
  to:
    kind: Service
    name: aiops-topology-dns-observer
    weight: 100
  wildcardPolicy: None
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: asm-svt-search
  labels:
    app.kubernetes.io/name: search
    app.kubernetes.io/instance: asm-svt
spec:
  host: asm-svt-${OPENSHIFT_PROJECT}.${PROXY_DOMAIN}
  path: /1.0/search
  port:
    targetPort: https-search-api
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: reencrypt
  to:
    kind: Service
    name: aiops-topology-search
    weight: 100
  wildcardPolicy: None
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: asm-svt-status
  labels:
    app.kubernetes.io/name: status
    app.kubernetes.io/instance: asm-svt
spec:
  host: asm-svt-${OPENSHIFT_PROJECT}.${PROXY_DOMAIN}
  path: /1.0/status
  port:
    targetPort: https-status-api
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: reencrypt
  to:
    kind: Service
    name: aiops-topology-status
    weight: 100
  wildcardPolicy: None
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: asm-svt-topology
  labels:
    app.kubernetes.io/name: topology
    app.kubernetes.io/instance: asm-svt
spec:
  host: asm-svt-${OPENSHIFT_PROJECT}.${PROXY_DOMAIN}
  path: /1.0/topology
  port:
    targetPort: https-topology-api
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: reencrypt
  to:
    kind: Service
    name: aiops-topology-topology
    weight: 100
  wildcardPolicy: None
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: asm-svt-ui-api
  labels:
    app.kubernetes.io/name: ui-api
    app.kubernetes.io/instance: asm-svt
spec:
  host: asm-svt-${OPENSHIFT_PROJECT}.${PROXY_DOMAIN}
  path: /1.0/ui-api
  port:
    targetPort: https-ui-api
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: reencrypt
  to:
    kind: Service
    name: aiops-topology-ui-api
    weight: 100
  wildcardPolicy: None
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: asm-svt-observer-service
  labels:
    app.kubernetes.io/name: observer-service
    app.kubernetes.io/instance: asm-svt
spec:
  host: asm-svt-${OPENSHIFT_PROJECT}.${PROXY_DOMAIN}
  path: /1.0/observer
  port:
    targetPort: https-observer-service-api
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: reencrypt
  to:
    kind: Service
    name: aiops-topology-observer-service
    weight: 100
  wildcardPolicy: None
EOF
