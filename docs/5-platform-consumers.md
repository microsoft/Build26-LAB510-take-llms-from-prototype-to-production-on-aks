## Module 5: Platform Consumer Path

**Duration:** ~5 minutes

**Objectives:**
By the end of this module, you will be able to:

- Configure GitHub Copilot in the terminal or VS Code to use your self-hosted models
- Understand how any OpenAI-compatible client can consume your AKS-hosted inference endpoints

With models running in your cluster, it's time to see this from the consumer side. In Module 4, you were the platform team building the serving layer. Now you're an application team using it.

> [!NOTE]
> This is the second of three production concerns: **easy consumption**. Internal teams should only need a base URL, a model name, and the standard OpenAI API format. No Kubernetes knowledge required.

### Integrate with Developer Tooling

A practical use case for self-hosted LLMs is **private, low-latency inference** for developer tools. Both [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-byok-models#model-requirements) and [VS Code](https://code.visualstudio.com/docs/copilot/customization/language-models) support bring-your-own-model (BYOM) configurations that point at any OpenAI-compatible endpoint. This is useful when:

- External model access is blocked by geographic or organizational policies
- API quota limits are reached
- Data sovereignty requires models to run within your own infrastructure
- You need predictable latency without internet round-trips

Since AI Runway exposes **OpenAI-compatible endpoints**, any tool that speaks this API can use your self-hosted models. The platform team handles the runtime complexity; consumers just point at a stable URL.

> [!WARNING]
> **Choose ONE of the two options below.** Both achieve the same result. Pick whichever workflow you prefer.

<details>
<summary>Option A: GitHub Copilot CLI</summary>

In the terminal, make sure you are in the root of the AI Runway repository. If not, run:

```bash
cd ~/airunway
```

GitHub Copilot CLI supports custom model providers through environment variables. Set these to point Copilot at your AKS-hosted model:

Get the inference gateway IP address:

```bash
GATEWAY_IP=$(kubectl get gateway -n istio-system inference-gateway -o jsonpath='{.status.addresses[0].value}')
```

Environment variables for custom model provider configuration:

```bash
export COPILOT_PROVIDER_BASE_URL=http://$GATEWAY_IP/v1
export COPILOT_PROVIDER_TYPE=openai
export COPILOT_MODEL=Qwen/Qwen3-Coder-30B-A3B-Instruct
export COPILOT_PROVIDER_MAX_PROMPT_TOKENS=128000
export COPILOT_PROVIDER_MAX_OUTPUT_TOKENS=16000
```

With these set, Copilot routes all completions through your self-hosted model instead of the public API. Inference stays private and within your network.

> [!TIP]
> You can run `copilot help providers` to see a full list of available options.

Then use Copilot with your local model:

```bash
copilot
```

When GitHub Copilot CLI loads, grant it permissions to access files in the current folder (**~/airunway**).

You should see that the Copilot CLI has loaded agent instructions from the AI Runway repo and has a few skills available.

Enter the following prompt: `Tell me everything I need to know about AI Runway`

![Copilot CLI connected to local Qwen/Qwen3-Coder-30B-A3B-Instruct model](instructions342912/m04cj0et.png)

</details>

<details>
<summary>Option B: VS Code</summary>

VS Code supports [custom language model configurations](https://code.visualstudio.com/docs/copilot/customization/language-models) that let Copilot use your self-hosted models.

Run the following command in your WSL terminal to get the gateway IP:

```bash
GATEWAY_IP=$(kubectl get gateway -n istio-system inference-gateway -o jsonpath='{.status.addresses[0].value}')
echo "Gateway IP: $GATEWAY_IP"
```

Then write the VS Code language model configuration file with your gateway IP filled in:

```bash
cat > "/mnt/c/Users/LabUser/AppData/Roaming/Code - Insiders/User/chatLanguageModels.json" <<EOF
[
  {
    "name": "OpenAI Compatible",
    "vendor": "customoai",
    "models": [
      {
        "id": "Qwen/Qwen3-Coder-30B-A3B-Instruct",
        "name": "Qwen/Qwen3-Coder-30B-A3B-Instruct",
        "url": "http://$GATEWAY_IP/v1",
        "toolCalling": true,
        "vision": true,
        "maxInputTokens": 128000,
        "maxOutputTokens": 16000
      }
    ]
  }
]
EOF
```

> [!TIP]
> The path above points to the VS Code settings folder on the Windows filesystem, accessed from WSL via `/mnt/c/`. If you're running VS Code natively on Linux or macOS, the path would be different (for example, `~/.config/Code/User/` on Linux).

This tells VS Code where to find your self-hosted model so Copilot can use it instead of the default cloud-hosted models. No manual editing needed.

In VS Code, click the Copilot icon in the editor to toggle open the Copilot pane. Click on **Auto** to open the model selector.

![VS Code editor showing Copilot pane with custom model selected](instructions342912/sl1rnawg.png)

Click on the model selector and select **Other Models** to expand the options.

![VS Code showing custom model in the model selector dropdown](instructions342912/xv7bo5ip.png)

You should see your custom model (**Qwen/Qwen3-Coder-30B-A3B-Instruct**) listed under the **OpenAI Compatible** provider. Click it.

![VS Code showing OpenAI Compatible models](instructions342912/fta32rld.png)

Now Copilot in VS Code routes all completions through your self-hosted model running in AKS.

Enter the following prompt: `Tell me everything I need to know about AI Runway`

![Chat prompt](instructions342912/eomh6cal.png)

</details>

> [!TIP]
> The first response from a self-hosted model may take longer than you're used to from cloud APIs. This is normal. The model is running on your cluster's GPUs, and the first request warms up the inference pipeline.

### Try These Prompts

Now that your developer tool is connected to the self-hosted model, try these prompts to explore what it can do with the AI Runway codebase. Each one tests a different capability:

**Codebase understanding:** Ask the model to explain how a core component works.

`How does the AI Runway controller decide which provider to use for a ModelDeployment?`

This tests whether the model can read the codebase, find the selection logic, and explain it clearly. Compare the answer to what you learned about auto-selection in Module 3.

**Code generation:** Ask it to write something new based on existing patterns.

`Write a ModelDeployment manifest that deploys deepseek-ai/DeepSeek-Coder-V2-Lite-Instruct on a single GPU using the vLLM engine`

Check whether the output follows the same CRD structure you've been using. Does it include the right apiVersion? Does the resource spec make sense given what you know about the fields?

**Tool calling:** Ask it to run a command and interpret the result.

`What ModelDeployments are currently running in my cluster? Show me their providers and engines.`

This tests tool calling: the model should invoke kubectl, parse the output, and summarize it. You'll see the same deployments you created in earlier modules.

**Architecture reasoning:** Push it with a design question.

`If I wanted to add a new inference provider to AI Runway, what would I need to implement? Walk me through the steps.`

This tests whether the model can synthesize information across multiple files (the provider interface, registration pattern, and controller logic) into a coherent answer.

> [!TIP]
> These prompts are optional. Feel free to try as many as you like, or move on to the next module if you're running short on time. Responses from a 30B parameter model running on 2 GPUs won't match the speed of cloud-hosted frontier models. That's expected. The point here is that inference stays entirely within your network, and the same OpenAI-compatible API works regardless of where the model runs.

**What you learned in this module:**

- AI Runway exposes **OpenAI-compatible endpoints**, so any tool that supports the OpenAI API can use your self-hosted models
- Both GitHub Copilot CLI and VS Code support bring-your-own-model configurations pointing at your gateway endpoint
- Self-hosted inference addresses data sovereignty, quota limits, and network locality requirements

> [!NOTE]
> **Checkpoint:** You've addressed two of three production concerns: reliable serving at scale and easy consumption. If time allows, continue with the optional operations module to complete the set with operational confidence.

---

Next [Module 6: Operate the Platform](6-platform-engineering.md)