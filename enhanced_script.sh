#!/bin/bash

# Required: sudo apt install jq bc
OUTPUT_FILE="benchmark_results.csv"

# Initialize CSV header
echo "prompt_type,iteration,tokens,duration_sec,tps,memory_free_mb" > $OUTPUT_FILE

# Define test cases: Short (Chat), Medium (Instructions), Long (Creative)
PROMPTS=("Hi" "Write a 3-sentence summary of cloud computing." "Explain the history of the internet in detail.")
PROMPT_LABELS=("Short" "Medium" "Long")

echo "Starting Enhanced Benchmark for ColdCountryPeople2..."
echo "Results will be saved to $OUTPUT_FILE"

for i in "${!PROMPTS[@]}"; do
    LABEL=${PROMPT_LABELS[$i]}
    PROMPT=${PROMPTS[$i]}
    
    echo "Testing Prompt Category: $LABEL"
    
    # Run 5 iterations per prompt for a better statistical average
    for iter in {1..5}; do
        echo -n "  Iteration $iter... "
        
        # Capture memory usage before inference
        MEM_BEFORE=$(free -m | awk '/^Mem:/{print $4}')
        
        # Trigger inference
        RESPONSE=$(curl -s http://localhost:11434/api/generate -d "{
          \"model\": \"qwen2.5:0.5b\",
          \"prompt\": \"$PROMPT\",
          \"stream\": false
        }")

        # Parse JSON
        TOKENS=$(echo $RESPONSE | jq -r .eval_count)
        DUR_NS=$(echo $RESPONSE | jq -r .eval_duration)
        
        # Calculate Metrics
        DUR_SEC=$(echo "scale=4; $DUR_NS / 1000000000" | bc)
        TPS=$(echo "scale=2; $TOKENS / $DUR_SEC" | bc)
        
        # Log to CSV
        echo "$LABEL,$iter,$TOKENS,$DUR_SEC,$TPS,$MEM_BEFORE" >> $OUTPUT_FILE
        echo "Done ($TPS TPS)"
    done
done

echo "Benchmark Complete. You can now import $OUTPUT_FILE into Excel or Sheets for your report charts."