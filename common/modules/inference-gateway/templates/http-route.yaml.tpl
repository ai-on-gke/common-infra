apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: ${NAME}
  namespace: ${NAMESPACE}
spec:
  parentRefs:
  - name: ${GATEWAY_NAME}
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /v1/completions
        #value: /
    backendRefs:
    - name: ${INFERENCE_POOL_NAME}
      group: inference.networking.x-k8s.io
      kind: InferencePool
