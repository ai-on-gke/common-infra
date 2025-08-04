apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: ${NAME}
  namespace: ${NAMESPACE}
spec:
  gatewayClassName: ${GATEWAY_CLASS}
  listeners:
      %{ if MANAGED_CERT_NAME != "" }
    - protocol: HTTPS
      port: 443
      name: https
      tls:
        mode: Terminate
        options:
          networking.gke.io/cert-manager-certs: ${MANAGED_CERT_NAME}
      %{ else }
    - protocol: HTTP
      port: 80
      name: http
      %{ endif }
  addresses:
  - type: NamedAddress
    value: ${IP_ADDRESS_NAME}
