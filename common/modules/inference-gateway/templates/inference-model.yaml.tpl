apiVersion: inference.networking.x-k8s.io/v1alpha2
kind: InferenceModel
metadata:
  name: ${NAME}
  namespace: ${NAMESPACE}
spec:
  modelName: ${MODEL_NAME}
  criticality: ${CRITICALITY}
  poolRef:
    name: ${INFERENCE_POOL_NAME}
  %{ if length(TARGET_MODELS) != 0 }
  targetModels:
  %{ for tm in TARGET_MODELS }
  - name: ${tm.name}
    weight: ${tm.weight}
  %{ endfor }
  %{ endif }
