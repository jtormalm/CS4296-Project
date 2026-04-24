#!/bin/bash

echo "--- Initializing Setup for ColdCountryPeople2 ---"

# 1. Update system and install benchmark dependencies
echo "Installing jq and bc..."
sudo apt-get update -y
sudo apt-get install -y jq bc curl

# 2. Install Ollama
echo "Downloading and installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# 3. Configure Ollama for 2GB RAM constraints
echo "Configuring low-memory environment variables..."
# We stop the default service to run it with custom flags
sudo systemctl stop ollama

# Create a wrapper or export variables for the session
export OLLAMA_KV_CACHE_TYPE=q4_0
export OLLAMA_NUM_PARALLEL=1

# 4. Start Ollama in the background
echo "Starting Ollama server in background mode..."
nohup ollama serve > ollama_server.log 2>&1 &
sleep 5 # Wait for server to initialize

# 5. Prepare the Custom Model Profile
echo "Creating Modelfile for Qwen-Tiny (1024 context)..."
cat << 'MOD' > Modelfile
FROM qwen2.5:0.5b
PARAMETER num_ctx 1024
PARAMETER temperature 0.7
MOD

# 6. Build the model
echo "Building qwen-tiny model..."
ollama create qwen-tiny -f Modelfile

echo "--- Setup Complete ---"
echo "You can now run ./enhanced_benchmark.sh to collect data."
