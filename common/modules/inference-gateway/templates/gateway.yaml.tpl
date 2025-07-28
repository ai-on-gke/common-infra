apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: ${NAME}
  namespace: ${NAMESPACE}
spec:
  gatewayClassName: ${GATEWAY_CLASS}
  listeners:
    - protocol: HTTP
      port: 80
      name: http
