apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: ${NAME}
  namespace: ${NAMESPACE}
spec:
  parentRefs:
  - name: ${GATEWAY_NAME}
  %{ if HOSTNAME != "" }
  hostnames:
  - ${HOSTNAME}
  %{ endif }
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: ${PATH}
    backendRefs:
    - kind: InferencePool
      group: inference.networking.x-k8s.io
      name: ${INFERENCE_POOL_NAME}
