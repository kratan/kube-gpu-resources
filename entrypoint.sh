#!/bin/sh

set -e
set -x

. /metadata.env

echo "[$(date)] Kubernetes endpoints: ${KUBERNETES_ENDPOINTS:-<none>})"
test -n "${KUBERNETES_ENDPOINTS}" || exit 1

echo "[$(date)] Node: ${NODE_NAME:-<unknown>}"
test -n "${NODE_NAME}" || exit 1

resource=gpu
value=`ls /sys/class/drm/ | egrep '^card[0-9]+$' | wc -l`

echo "[$(date)] Resources:"
echo "            ${resource:-<unknown>}: ${value:-<unknown>}"

echo "[$(date)] Searching for Kubernetes endpoint ..."
while ! [[ "${endpoint}" ]] ; do
	for e in ${KUBERNETES_ENDPOINTS/,/ } ; do
		if curl --silent --fail "${e}/version" \
			--cert   ${KUBE_CERT_FILE} \
			--key    ${KUBE_KEY_FILE} \
			--cacert ${KUBE_CA_CERT_FILE} > /dev/null ; then
			endpoint="${e}"
			break
		fi
	done
	sleep 1
done

echo "[$(date)] Publishing resources ..."
curl --silent --fail "${endpoint}/api/v1/nodes/${NODE_NAME}/status" \
	--cert   ${KUBE_CERT_FILE} \
	--key    ${KUBE_KEY_FILE} \
	--cacert ${KUBE_CA_CERT_FILE} \
	--request PATCH \
	--header "Accept: application/json" \
	--header "Content-Type: application/json-patch+json" \
	--data @- \
	<<- EOF
[
  {
    "op": "add",
    "path": "/status/capacity/pod.alpha.kubernetes.io~1opaque-int-resource-${resource}",
    "value": "${value}"
  }
]
EOF
