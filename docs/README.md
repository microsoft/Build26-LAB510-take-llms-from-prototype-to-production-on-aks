# Take LLMs from prototype to production on AKS

## Lab Setup

Provision infrastructure

```bash
cd src/infra/terraform
terraform init
terraform apply
```

Set environment variables

```bash
RG_NAME=$(terraform output -raw rg_name)
AKS_NAME=$(terraform output -raw aks_name)
LFS_NAME=$(terraform output -raw lfs_name)
```

Navigate back to the root of the repo

```bash
cd ../../../
```

Connect to the AKS cluster

```bash
az aks get-credentials \
--resource-group $RG_NAME \
--name $AKS_NAME \
--overwrite
```

Make sure the Argo CD installations are up and running

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo;
kubectl -n argocd port-forward svc/argo-cd-argocd-server 9000:80 &

# or 

kubectl -n argocd port-forward svc/argo-cd-argocd-server 9000:80 &>/dev/null &
ARGOCD_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argocd login localhost:9000 --username admin --password "$ARGOCD_PWD" --insecure
argocd app list
```

Wait for the grove-operator pod to stabilize. On initial install, the grove operator's built-in cert-controller refreshes webhook TLS certificates, writes them to a secret, and exits (exit code 0) expecting a restart to pick up the new certs. This causes a brief CrashLoopBackOff that resolves itself after 1-2 restarts once the certs stabilize. If it persists, run:

```sh
kubectl rollout restart -n dynamo-system deploy grove-operator
```

## Getting Started with AI Runway

To run the AI Runway dashboard app from source, clone the repo

```bash
git clone https://github.com/kaito-project/airunway.git
cd airunway
```

Build and run the app

```bash
bun install
bun run dev
```

Open a web browser and navigate to [http://localhost:5173](http://localhost:5173)

## Quick tour of AI Runway

### Settings

Navigate to the Settings page in the left sidebar. Here you'll see the current connection status and cluster information:

- **Connection**: Displays the current connection status (Connected/Disconnected)
- **Cluster**: Shows the name of the AKS cluster you're connected to (e.g., `aks-msbuildlab510`)
- **Runtimes Installed**: Displays the number of inference runtimes currently installed and configured on your cluster

This dashboard provides an overview of your cluster's readiness to deploy and run LLM inference workloads.

#### Integrations

Click on the **Integrations** tab to view and manage the integrations available for your AI Runway instance.

You should see the following integrations available which are essential for a production-ready inference platform:

- **NVIDIA GPU Operator:** Automates the deployment, configuration, and lifecycle management of NVIDIA GPUs across a Kubernetes cluster by dynamically provisioning drivers, device plugins, container toolkits, and monitoring components on GPU-enabled nodes.
- **Gateway API with Inference Extension:** Provides the unified API and routing layer required for consistent model access across your deployment.
- **HuggingFace Token:** Connects to gated models on HuggingFace Hub. Required if your deployment uses restricted or proprietary models.

The AI Runway provides an easy way to enable the GPU Operator. Just toggle the switch next to the NVIDIA GPU Operator integration to enable or disable it.

> [!note]
> Enabling the NVIDIA GPU Operator can take a few minutes to complete.

Next, click the **Install CRDs** button within the **Gateway API** section to install the necessary Custom Resource Definitions for the Gateway API with Inference Extension. This step is required to enable the unified API and routing layer for consistent model access across your deployment.

Finally, click the **Sign in with Hugging Face** button to authenticate your AI Runway instance with HuggingFace Hub.

> [!note]
> If you don't already have a Hugging Face account, you can create one at [https://huggingface.co/join](https://huggingface.co/join).

#### Runtimes

Runtimes are the inference engines that execute your machine learning models on the cluster. Click on the **Runtimes** tab to view the available runtimes and their statuses.

In the **Prerequisites** section you'll see information that indicates you are connected to the cluster and have the necessary tools (Helm CLI) installed to deploy inference runtimes.

> A green checkmark indicates the Helm CLI is Connected and Available, meaning you have the necessary tools installed to deploy inference runtimes to your cluster. This is a prerequisite check — if Helm weren't installed or configured properly, you wouldn't be able to proceed with runtime deployments.

The **Cluster Autoscaling** section shows that your cluster is setup to automatically provision additional compute resources when needed. This may be essential for running large language models at scale.

The **Available Runtimes** section displays inference providers registered with your AI Runway instance.

Currently it shows "No inference providers are registered"

To get started, you need to deploy an InferenceProviderConfig to register available runtimes (such as KAITO, Dynamo, KubeRay, or llm-d).

Once registered, these runtimes will appear here and be ready for deployment.
This is where you'll see all the AI inference options available in your cluster once they're configured.

In the terminal run the following to deploy all the supported inference providers:



Within a minute or so, the NVIDIA Dynamo inference provider should appear in the Available Runtimes section, indicating that it is ready for deployment, (but not quite. You still need to deploy the runtime itself to make it fully operational??).

In the **Dynamo Installation** section, you will find the steps to deploy the NVIDIA Dynamo runtime itself. This involves installing the Helm chart which you can simply copy and paste into your terminal to deploy the runtime. (or click the Install button in the UI??)

You're now ready to deploy your first model!

## Model Deployment

To deploy a model, click on the **Models** tab in the left navigation pane. This will display a list of available models that you can deploy to your AI Runway instance. Click the **Deploy** link for the **Qwen3 0.6B** model. Select NVIDIA Dynamo as the runtime and leave all the other settings at their default values and click **Deploy**. 

Within a few minutes you should see the model status change to **Running**, indicating that the model has been successfully deployed and is ready to serve inference requests.

Click on the model and you will see an example request. Copy the command and run in your terminal to test the deployed model.

You should see the model's output in your terminal, indicating that the deployed model is functioning correctly and serving inference requests.

Delete the model by clicking on the **Delete** button in the model details page.

Let's move on to a more advanced scenario.


```
kubectl apply -f - <<EOF
apiVersion: airunway.ai/v1alpha1
kind: ModelDeployment
metadata:
  name: qwen3-6-27b-ovgb
  namespace: dynamo-system
  labels:
    app.kubernetes.io/name: airunway
    app.kubernetes.io/instance: qwen3-6-27b-ovgb
    app.kubernetes.io/managed-by: airunway
spec:
  image: vllm/vllm-openai:v0.19.1
  model:
    id: Qwen/Qwen3.6-27B
    source: huggingface
  engine:
    type: vllm
    trustRemoteCode: false
  serving:
    mode: aggregated
  provider:
    name: dynamo
  scaling:
    replicas: 1
  resources:
    gpu:
      count: 1
      type: nvidia.com/gpu
EOF
```


```
kubectl apply -f - <<EOF
apiVersion: airunway.ai/v1alpha1
kind: ModelDeployment
metadata:
  name: qwen3-6-27b-ihvb
  namespace: default
  labels:
    app.kubernetes.io/name: airunway
    app.kubernetes.io/instance: qwen3-6-27b-ihvb
    app.kubernetes.io/managed-by: airunway
spec:
  image: vllm/vllm-openai:v0.19.1
  model:
    id: Qwen/Qwen3.6-27B
    source: huggingface
  engine:
    type: vllm
    trustRemoteCode: false
  serving:
    mode: aggregated
  provider:
    name: llmd
  scaling:
    replicas: 1
  resources:
    gpu:
      count: 1
      type: nvidia.com/gpu
EOF
```


## Disagregated Model Deployment

In a disaggregated model deployment, the model's components (such as the encoder and decoder) are deployed separately, allowing for more flexible scaling and resource allocation. This can be particularly useful for large models where different components have different computational requirements.

https://huggingface.co/Qwen/Qwen3.6-27B

## VS Code


Command Palette → Chat: Open Language Models (JSON)

```
[
	{
		"name": "OpenAI Compatible",
		"vendor": "customoai",
		"models": [
			{
				"name": "DeepSeek-R1-Distill-Llama-8B",
				"modelId": "deepseek-ai/DeepSeek-R1-Distill-Llama-8B",
				"baseUrl": "http://4.228.4.196/v1",
				"apiKey": "none",
				"toolCalling": true,
				"vision": true
			}
		]
	}
]
```

Command Palette → Developer: Reload Window


Managed Lustre File System (LFS)

```bash
curl -skSL https://raw.githubusercontent.com/kubernetes-sigs/azurelustre-csi-driver/main/deploy/install-driver.sh | bash -s main
```

```bash
LFS_IP=$(az amlfs show \
--name $LFS_NAME \
--resource-group $RG_NAME \
--query clientInfo.mgsAddress \
--output tsv)
```

```bash
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurelustre-static
provisioner: azurelustre.csi.azure.com
parameters:
  mgs-ip-address: $LFS_IP
reclaimPolicy: Retain
volumeBindingMode: Immediate
mountOptions:
  - noatime
  - flock
EOF
```

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-lustre
  namespace: dynamo-system
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 4Ti
  storageClassName: azurelustre-static
EOF
```


```bash
kubectl apply -f - <<EOF
apiVersion: airunway.ai/v1alpha1
kind: ModelDeployment
metadata:
  name: deepseek-r1-dist-02pt
  namespace: dynamo-system
  labels:
    app.kubernetes.io/name: airunway
    app.kubernetes.io/instance: deepseek-r1-dist-02pt
    app.kubernetes.io/managed-by: airunway
spec:
  model:
    id: deepseek-ai/DeepSeek-R1-Distill-Llama-8B
    source: huggingface
    storage:
      volumes:
        - name: vol-1
          purpose: modelCache
          mountPath: /model-cache
          readOnly: false
          claimName: pvc-lustre # in the ui make sure to select existing disk
  engine:
    type: vllm
    trustRemoteCode: false
  serving:
    mode: disaggregated
  provider:
    name: dynamo
```

```bash
kubectl apply -f - <<EOF
apiVersion: airunway.ai/v1alpha1
kind: ModelDeployment
metadata:
  name: ministral-3-8b-i-8bvf
  namespace: dynamo-system
  labels:
    app.kubernetes.io/name: airunway
    app.kubernetes.io/instance: ministral-3-8b-i-8bvf
    app.kubernetes.io/managed-by: airunway
spec:
  model:
    id: mistralai/Ministral-3-8B-Instruct-2512-BF16
    source: huggingface
    storage:
      volumes:
        - name: vol-1
          purpose: modelCache
          mountPath: /model-cache
          readOnly: false
          claimName: pvc-lustre
  engine:
    type: vllm
    trustRemoteCode: false
  serving:
    mode: disaggregated
  provider:
    name: dynamo
  scaling:
    prefill:
      replicas: 1
      gpu:
        count: 1
        type: nvidia.com/gpu
    decode:
      replicas: 1
      gpu:
        count: 1
        type: nvidia.com/gpu
EOF
```

```bash
INFERENCE_GATEWAY_IP=$(kubectl get svc inference-gateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```


```json
[
	{
		"name": "OpenAI Compatible",
		"vendor": "customoai",
		"models": [
			{
				"name": "Ministral-3-8B-Instruct-2512-BF16",
				"modelId": "mistralai/Ministral-3-8B-Instruct-2512-BF16",
				"baseUrl": "http://4.228.0.129/v1",
				"apiKey": "none",
				"vision": true
			}
		]
	}
]
```

```bash
export COPILOT_PROVIDER_BASE_URL=http://$INFERENCE_GATEWAY_IP/v1
export COPILOT_PROVIDER_TYPE=openai
export COPILOT_MODEL=mistralai/Ministral-3-8B-Instruct-2512-BF16
export COPILOT_OFFLINE=true
```

```bash
copilot
```



https://huggingface.co/Qwen/Qwen3.5-35B-A3B