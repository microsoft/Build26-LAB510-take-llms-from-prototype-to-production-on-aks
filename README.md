<p align="center">
<img src="img/banner-build-26.png" alt="Microsoft Build 2026" width="1200"/>
</p>

# [Microsoft Build 2026](https://build.microsoft.com)

## 🔥 [LAB510: Take LLMs from prototype to production on AKS](https://build.microsoft.com/sessions/LAB510)

### Session Description

Moving an AI model from experiment to production is hard. Learn about AI Runway, an open-source accelerator that simplifies deploying LLMs on Azure Kubernetes Service (AKS). By treating models as native Kubernetes resources, AI Runway offers a single interface that adapts to multiple inference backends. You’ll deploy a production LLM on AKS, implement custom resources for scaling and networking, configure GPU and latency monitoring, and integrate it into CI/CD pipelines.

### 🏠 Getting started

To get started with this lab:
- Clone this repository
- Install the [required tools](docs/README.md#required-tools) (Azure CLI, kubectl, Bun, Helm, jq, yq)
- Provision infrastructure using the Terraform configuration in `src/infra/` (requires an Azure subscription with GPU quota)
- Connect to your AKS cluster and start with [Module 1: First Deployment & Core Concepts](docs/1-core-concepts.md)

### 🧠 Learning Outcomes

By the end of this lab, you will be able to:

- Deploy LLMs on AKS using AI Runway's ModelDeployment custom resource
- Configure disaggregated serving and shared model caching for production workloads
- Route inference traffic to multiple models through a single gateway endpoint
- Connect developer tools to self-hosted OpenAI-compatible model endpoints
- Monitor inference deployments with Prometheus metrics and DORA indicators

### 💬 Keep Learning with Copilot

Try these prompts with GitHub Copilot to explore the topics from this lab. Open Copilot Chat in VS Code (`Ctrl+Alt+I` on Windows/Linux, `Cmd+Shift+I` on Mac), paste a prompt, and see what you learn. Try connecting the [Microsoft Learn MCP Server](#-microsoft-learn-mcp-server) for the latest official documentation.

Use these as a starting point — or write your own!

- "How does AI Runway decide which inference provider to use for a ModelDeployment?"
- "What is disaggregated prefill/decode and when should I use it?"
- "How does the Gateway API Inference Extension route requests to different models?"
- "Write a ModelDeployment manifest that deploys a model on GPU with vLLM"
- "What are the DORA metrics for AI inference platforms and how do I track them?"

### 💻 Technologies Used

1. [Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/)
1. [AI Runway](https://github.com/kaito-project/airunway)
1. [KAITO (Kubernetes AI Toolchain Operator)](https://github.com/kaito-project/kaito)
1. [NVIDIA Dynamo](https://developer.nvidia.com/dynamo)
1. [Gateway API Inference Extension](https://gateway-api-inference-extension.sigs.k8s.io/)
1. [Azure Managed Lustre](https://learn.microsoft.com/azure/azure-managed-lustre/)
1. [Argo CD](https://argo-cd.readthedocs.io/)
1. [Prometheus & Grafana](https://prometheus.io/)

### 📚 Resources and Next Steps

| Resource | Description |
|:---------|:------------|
| [AI Runway GitHub Repository](https://github.com/kaito-project/airunway) | Open-source accelerator for deploying LLMs on Kubernetes |
| [KAITO Project](https://github.com/kaito-project/kaito) | Kubernetes AI Toolchain Operator (CNCF Sandbox) |
| [Gateway API Inference Extension](https://gateway-api-inference-extension.sigs.k8s.io/) | Inference-aware routing for Kubernetes Gateway API |
| [Deploy AI models on AKS with KAITO](https://learn.microsoft.com/azure/aks/ai-toolchain-operator) | Microsoft Learn documentation for KAITO on AKS |
| [Use GPU-based workloads on AKS](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks-gpu/gpu-aks) | Reference architecture for GPU workloads on AKS |
| [Azure Managed Lustre](https://learn.microsoft.com/azure/azure-managed-lustre/amlfs-overview) | High-performance shared storage for model caching |
| [https://aka.ms/build26-next-steps](https://aka.ms/build26-next-steps) | Take the next step in your learning journey after Build 2026 |


### 🌟 Microsoft Learn MCP Server

[![Install in VS Code](https://img.shields.io/badge/VS_Code-Install_Microsoft_Docs_MCP-0098FF?style=flat-square&logo=visualstudiocode&logoColor=white)](https://vscode.dev/redirect/mcp/install?name=microsoft.docs.mcp&config=%7B%22type%22%3A%22http%22%2C%22url%22%3A%22https%3A%2F%2Flearn.microsoft.com%2Fapi%2Fmcp%22%7D)

The Microsoft Learn MCP Server is a remote MCP Server that enables clients like GitHub Copilot and other AI agents to bring trusted and up-to-date information directly from Microsoft's official documentation. Get started by using the one-click button above for VSCode or access the [mcp.json](.vscode/mcp.json) file included in this repo.

For more information, setup instructions for other dev clients, and to post comments and questions, visit our Learn MCP Server GitHub repo at [https://github.com/MicrosoftDocs/MCP](https://github.com/MicrosoftDocs/MCP). Find other MCP Servers to connect your agent to at [https://mcp.azure.com](https://mcp.azure.com).

*Note: When you use the Learn MCP Server, you agree with [Microsoft Learn](https://learn.microsoft.com/en-us/legal/termsofuse) and [Microsoft API Terms](https://learn.microsoft.com/en-us/legal/microsoft-apis/terms-of-use) of Use.*

## Content Owners

<table>
<tr>
    <td align="center"><a href="https://github.com/pauldotyu">
        <img src="https://github.com/pauldotyu.png" width="100px;" alt="Paul Yu"/><br />
        <sub><b>Paul Yu</b></sub></a><br />
            <a href="https://github.com/pauldotyu" title="talk">📢</a>
    </td>
</tr></table>

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [Contributor License Agreements](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
