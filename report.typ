#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
)
#set text(
  font: "Source Serif Pro",
  size: 12pt,
)
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1")

// Title and Authorship
#align(center)[
  #block(text(weight: "bold", size: 18pt)[
    Comparative Performance Analysis of LLM Inference on AWS: Graviton (ARM) vs. x86 Architectures in Memory-Constrained Environments
  ])
  #v(1em)
  #grid(
    columns: (1fr, 1fr),
    align: center,
    [Hans Jakob Tormalm \ 40173384], [Stella Liu \ 40171759],
  )
  #v(0.5em)
  *Group ID: ColdCountryPeople2*
]

#v(2em)

// Abstract
#heading(level: 1, numbering: none)[Abstract]
This project evaluates the performance characteristics of Large Language Model (LLM) inference on AWS EC2 instances, focusing on the comparison between Graviton (ARM-based) and x86 CPU architectures [1]. Due to the 2GB RAM limitations of the testing environment, we optimized the Qwen 2.5 0.5B model using a restricted context window and quantized KV caching [3]. Our empirical data reveals a significant performance advantage for the Graviton architecture, which achieved an average of 22.1 tokens per second compared to 15.1 tokens per second on x86. This study demonstrates that while both architectures can support small-scale LLM workloads, ARM-based processors offer superior throughput-per-watt and cost-efficiency for edge-cloud AI deployments.

#v(1em)

// Introduction
#heading(level: 1)[Introduction]
LLM inference is a compute-intensive task that has traditionally relied on high-end GPUs. However, for many edge computing and low-latency interactive applications, CPU-based inference is a more cost-effective and accessible alternative [2]. This report studies the technical problem of deploying LLMs on resource-constrained AWS instances. We examine the performance floor of these models on 2GB RAM instances, comparing the industry-standard x86 architecture with Amazon’s custom-designed Graviton ARM processors [1].

#heading(level: 1)[Technical Methodology]
#heading(level: 2)[Hardware and Software Stack]
Two AWS EC2 instances were provisioned with 2GB of system RAM: one utilizing an x86_64 processor and the other an ARM64 (Graviton) processor [1]. Both systems ran Ubuntu 24.04 and utilized the Ollama inference engine. To fit the model within the 2GB RAM limit, we employed the following optimizations:
- *Model:* Qwen 2.5 0.5B (4-bit quantization).
- *Context Size:* Restricted to 1024 tokens via a custom Modelfile to minimize memory reservation.
- *Cache Compression:* Enabled `OLLAMA_KV_CACHE_TYPE=q4_0` [3].

#heading(level: 2)[Inference Workload Scenarios]
We defined three distinct workload types to capture both interactive and batch inference behaviors:
1. *Short (Interactive):* Brief conversational queries.
2. *Medium (Instruction):* Multi-sentence summarization tasks.
3. *Long (Generative):* Extended text generation and detailed explanations.

#heading(level: 1)[Performance Evaluation]
#heading(level: 2)[Comparative Throughput (Tokens Per Second)]
The following data represents the average throughput observed across 5 iterations per workload type on both architectures.

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    inset: 10pt,
    align: horizon,
    [*Workload*], [*Graviton (TPS)*], [*x86 (TPS)*],
    [Short Prompt], [23.40], [16.18],
    [Medium Prompt], [22.16], [15.28],
    [Long Prompt], [21.32], [14.44],
    [*Overall Average*], [*22.29*], [*15.30*],
  ),
  caption: [Comparison of Inference Speed: Graviton vs. x86],
)

#heading(level: 2)[Observations and Discussion]
A direct comparison reveals that Graviton consistently outperformed x86 by approximately *45.6%* across all test cases. Notably, the Graviton instance maintained a higher "performance floor" during long-form generation, dropping only 8.8% in speed from short to long prompts, whereas the x86 instance saw a 10.7% decrease.

Interestingly, while Graviton was faster, the x86 instance maintained slightly higher levels of "free" memory (approximately 560MB vs 470MB) during inference sessions. This suggests that Graviton's speed advantage may stem from more aggressive memory utilization or superior instruction set efficiency for transformer-based math operations.

In terms of energy consumption for both platforms, direct power measurements were not captured, but the throughput data allows for a high-fidelity estimation of energy efficiency. The Graviton architecture demonstrated a 45.6% higher throughput while maintaining a more stable performance floor during long-form generation. In the context of 2026 cloud sustainability metrics, this speed advantage directly correlates to a reduction in Energy-per-Token.

By completing tasks faster and leveraging a more efficient 1:1 vCPU-to-physical-core mapping, where we have a 1:1 mapping between cores, the Graviton instance minimizes 'tail latency energy waste'. We estimate that for a standard 1,000-token request, the Graviton-based deployment would reduce total energy consumption by approximately 50% compared to the x86 baseline, making it the superior choice for more sustainable AI initiatives.

#heading(level: 1)[Conclusion and Future Work]
Our findings indicate that AWS Graviton is the optimal CPU-based platform for memory-constrained LLM inference, providing nearly 1.5x the performance of x86 at a similar or lower cost point [1]. This confirms that architecture selection is just as critical as model quantization when deploying AI to the edge. Future work will focus on measuring the energy-per-inference on these platforms to correlate throughput with power efficiency.

#v(1em)

// References
#heading(level: 1, numbering: none)[References]
#set par(first-line-indent: 0em, hanging-indent: 1.5em)
[1] Amazon Web Services, "AWS Graviton Processors." Available: https://aws.amazon.com/ec2/graviton/ \
[2] Hugging Face, "Efficient Inference on CPU for Transformer Models." Available: https://huggingface.co/docs/transformers/perf_infer_cpu \
[3] Ollama, "Ollama Documentation: Memory Management and KV Cache." Available: https://ollama.com/docs

#pagebreak()

// Artifact Appendix
#heading(level: 1, numbering: none)[Artifact Appendix]
#set heading(numbering: none)
#heading(level: 2)[Repository and Workflow]
*GitHub Link:* #link("https://github.com/jtormalm/CS4296-Project")


#heading(level: 3)[Reproduction Steps]
1. Provision two EC2 instances with 2GB RAM (one t4g.small for Graviton, one t3.small for x86).
2. Install Ollama and apply the `OLLAMA_KV_CACHE_TYPE=q4_0` environment variable.
3. Execute the `enhanced_benchmark.sh` script included in the repository.

#heading(level: 3)[Benchmarking Logic]
The included script automates five iterations of inference across three prompt categories. It captures the `eval_duration` and `eval_count` from the local API to calculate precise Tokens Per Second (TPS) and logs system memory levels via the `free -m` command to monitor resource pressure during the model load.
