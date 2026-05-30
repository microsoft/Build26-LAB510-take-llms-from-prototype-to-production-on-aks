## Summary

### What You Built

You started with a single CPU model and a blank cluster. You ended with a multi-model inference platform that addresses all three production concerns:

**Reliable serving at scale.** Your Qwen Coder deployment runs disaggregated prefill and decode on separate GPUs, backed by shared Lustre storage so model weights download once and are available to every pod instantly. You deployed models across different hardware (CPU on KAITO with llama.cpp, GPU on Dynamo with vLLM) without writing any provider-specific configuration.

**Easy consumption.** Application teams hit one URL and specify a model name. The gateway handles body-based routing, inference-aware pod selection, and provider-specific optimizations like KV-cache affinity. You connected GitHub Copilot or VS Code to your self-hosted models with no external API calls and no data leaving your network.

**Operational confidence.** Prometheus metrics, Grafana dashboards, and DORA indicators show deployment health, rollout speed, and provider activity in real time. GitOps keeps everything declarative and repeatable.

> [!NOTE]
> Every pattern you used here carries over to production: declarative manifests, GitOps-managed rollout, shared gateway routing, and observable metrics. See [Appendix B](appendix-b.md) for a starting point you can adapt for your own environment.

### Get Involved

AI Runway is open source and still early. The patterns you just learned put you in a great position to shape where the project goes next. Here's how to stay connected:

- **Star the repo**: [github.com/kaito-project/airunway](https://github.com/kaito-project/airunway)
- **File issues**: Found a bug or have a feature request? Open an issue on GitHub
- **Join the community**: Connect with other users and contributors in the [#airunway channel](https://cloud-native.slack.com/archives/C0AQBU447QX) on CNCF Slack

### Additional Resources

- [AI Runway GitHub Repository](https://github.com/kaito-project/airunway)
- [KAITO Project (CNCF Sandbox)](https://github.com/kaito-project/kaito)
- [Gateway API Inference Extension](https://gateway-api-inference-extension.sigs.k8s.io/)
- [Deploy AI models on AKS with KAITO](https://learn.microsoft.com/azure/aks/ai-toolchain-operator)
- [Use GPU-based workloads on AKS](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks-gpu/gpu-aks)
- [Azure Managed Lustre CSI Driver](https://learn.microsoft.com/azure/azure-managed-lustre/use-csi-driver-kubernetes)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/en/stable/)

The appendixes that follow cover the full provider capability matrix, troubleshooting tips, and a guide for reproducing this setup in your own environment.

## Cleanup

When you're finished with the lab, run the following command in your terminal (from the `src/infra` directory) to clean up all resources:

```bash
terraform destroy -refresh=false -auto-approve
```

---

## Appendix

[Appendix A: Provider Capability Matrix & Selection Rules](appendix-a.md)
[Appendix B: Reproduce This Lab in Your Own Environment](appendix-b.md)
[Appendix C: Troubleshooting Tips](appendix-c.md)