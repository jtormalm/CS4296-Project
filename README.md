# Cost-Performance Analysis of LLM Inferencing on AWS
**Group ID:** ColdCountryPeople2  
**Project Nature:** Technical

This repository contains the benchmarking suite and optimization scripts used to evaluate the performance of Large Language Model (LLM) inferencing on resource-constrained AWS EC2 instances. The evaluation focuses on latency and throughput, capturing both interactive and generative workloads.

## Prerequisites

To ensure reproducibility, the experiments must be conducted on a system meeting the following hardware and software specifications:

* **Operating System:** Amazon Linux 2023 (Kernel 6.1).
* **Instance Types:** t3.small (x86_64 architecture) or t4g.small (ARM64 / Graviton architecture).
* **Memory:** 2GB RAM (Critical constraint for this study).
* **Storage:** 32GB EBS volume.

---

## Installation and Setup

The setup process is automated to configure the Ollama inference engine and optimize it for low-memory environments.

1. **Prepare the Repository:**
   Navigate to the directory where you have downloaded this project.

2. **Run the Setup Script:**
   This script installs necessary dependencies (jq, bc), downloads Ollama, configures quantized KV caching, and builds the custom model profile.
   
   chmod +x setup_project.sh
   
   ./setup_project.sh

---

## Running Benchmarks

### 1. Automated Data Collection
To generate a comprehensive CSV file for performance analysis, including tokens per second and memory usage across iterations, run the following:

chmod +x enhanced_benchmark.sh

./enhanced_benchmark.sh

The results will be saved to benchmark_results.csv.

### 2. Visual Demo
To view a real-time, formatted demonstration of the model's inference speed and response quality as seen in the project demo video, run:

chmod +x demo_benchmark.sh

./demo_benchmark.sh

---

## Manual Testing with Ollama

If you wish to interact with the optimized model manually to verify its stability within the 2GB RAM limit, use the following commands:

1. **Ensure the server is running with low-memory flags:**
   
   export OLLAMA_KV_CACHE_TYPE=q4_0
   
   ollama serve

2. **Run the model in a separate terminal:**
   
   ollama run qwen-tiny

---

## Artifact Appendix

For a detailed formal description of all supporting materials, models, and workflows used in this project, please refer to the Artifact Appendix in our Final Project Report.