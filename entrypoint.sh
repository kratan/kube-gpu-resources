#!/bin/sh

set -e
set -x

endpoint=http://127.0.0.1:8080
resource=gpu
value=`ls /sys/class/drm/ | egrep '^card[0-9]+$' | wc -l`

echo "[$(date)] Node: ${NODE_NAME:-<unknown>}"
echo "[$(date)] Resources:"
echo "            ${resource:-<unknown>}: ${value:-<unknown>}"

test -n "${NODE_NAME}" || exit 1

while ! curl --silent --fail "${endpoint}/version" ; do
	sleep 1
done

curl --fail \
     --request PATCH \
      --header "Accept: application/json" \
      --header "Content-Type: application/json-patch+json" \
      --data @- \
      "${endpoint}/api/v1/nodes/${NODE_NAME}/status" <<- EOF
[
  {
    "op": "add",
    "path": "/status/capacity/pod.alpha.kubernetes.io~1opaque-int-resource-${resource}",
    "value": "${value}"
  }
]
EOF
