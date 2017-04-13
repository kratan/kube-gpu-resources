# Kubernetes Opaque Integer Resources for GPUs

A simple container that counts GPUs listed in sysfs and creates Kubernetes [Opaque Integer Resources](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#opaque-integer-resources-alpha-feature) (OIR).

Run it by dropping the following as `kube-gpu-resources.yaml` into `/etc/kubernetes/manifests`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kube-gpu-resources
  namespace: kube-system
spec:
  restartPolicy: OnFailure
  containers:
  - name: kube-gpu-resources
    image: quay.io/urzds/kube-gpu-resources:v0.1.0
    env:
    - name: NODE_NAME
      valueFrom:
        fieldRef:
          fieldPath: status.nodeName
  - name: "kubectl-proxy"
    image: "quay.io/urzds/busybox-kubectl:v1.26.1-v1.5.1"
    args:
    - "proxy"
    - "--port=8080"
```

Internally it uses [Alpine Linux](http://alpinelinux.org/) with the [cURL](https://curl.haxx.se/) and [jq](https://stedolan.github.io/jq/) tools.

Similar to [urzds/kube-env-node-labels](https://github.com/urzds/kube-env-node-labels).
