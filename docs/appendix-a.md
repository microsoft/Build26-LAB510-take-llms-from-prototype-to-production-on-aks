## Appendix A: Provider Capability Matrix & Selection Rules

This reference covers the full provider capability matrix and auto-selection algorithm. The workshop focused on the two most common paths (CPU → KAITO, GPU → Dynamo). Here's the complete picture.

### Provider Capability Matrix

| Capability                   | KAITO   | Dynamo            | KubeRay       | llm-d         |
| ---------------------------- | ------- | ----------------- | ------------- | ------------- |
| CPU inference                | Yes     | No                | No            | No            |
| GPU inference                | Yes     | **Yes**           | Yes           | Yes           |
| vLLM engine                  | Yes     | **Yes**           | Yes           | Yes           |
| SGLang engine                | No      | **Yes**           | No            | No            |
| TensorRT-LLM engine          | No      | **Yes**           | No            | No            |
| llama.cpp engine             | **Yes** | No                | No            | No            |
| Disaggregated prefill/decode | No      | **Yes**           | Yes           | Yes           |
| Auto-selection               | Yes     | Yes (default GPU) | No (explicit) | No (explicit) |

### Complete Auto-Selection Algorithm

When you omit **spec.provider.name**, the controller evaluates these rules in order:

1. **No GPU requested** → KAITO (only CPU-capable provider), engine auto-selected to **llamacpp**
2. **Engine is trtllm or SGLang** → Dynamo (only provider supporting these)
3. **Engine is llamacpp** → KAITO (only llamacpp provider)
4. **Disaggregated mode** → Dynamo (best disaggregated support)
5. **Default (GPU + vllm + aggregated)** → Dynamo (GPU inference default)

The selection reason is always recorded in **status.provider.selectedReason** for observability.

---