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
  hostNetwork: true
  restartPolicy: OnFailure
  containers:
  - name: kube-gpu-resources
    image: quay.io/urzds/kube-gpu-resources:v0.2.2
    env:
    - name: NODE_NAME
      valueFrom:
        fieldRef:
          fieldPath: spec.nodeName
    - name: KUBE_CERT_FILE
      value: /etc/kubernetes/ssl/kubelet.crt
    - name: KUBE_KEY_FILE
      value: /etc/kubernetes/ssl/kubelet.key
    - name: KUBE_CA_CERT_FILE
      value: /etc/kubernetes/ssl/ca.crt
    - name: KUBERNETES_ENDPOINTS
      value: ...
    volumeMounts:
    - mountPath: /etc/kubernetes/ssl
      name: ssl-certs-kubernetes
      readOnly: true
  volumes:
  - hostPath:
      path: /etc/kubernetes/ssl
    name: ssl-certs-kubernetes
```

Internally it uses [Alpine Linux](http://alpinelinux.org/) with [cURL](https://curl.haxx.se/).

Similar to [urzds/kube-env-node-labels](https://github.com/urzds/kube-env-node-labels).
