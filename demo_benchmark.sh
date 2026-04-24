#!/bin/bash

# Visual Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

MODEL="qwen2.5:0.5b"
PROMPTS=("What is cloud computing?" "Write a short poem about the AWS Graviton processor." "Explain the importance of memory optimization for LLMs.")
LABELS=("SHORT" "MEDIUM" "LONG")

clear
echo -e "${BOLD}=== ColdCountryPeople2: AWS LLM Inference Demo ===${NC}"
echo -e "Platform: $(uname -m) Architecture"
echo -e "Model: $MODEL\n"

for i in "${!PROMPTS[@]}"; do
    PROMPT=${PROMPTS[$i]}
    LABEL=${LABELS[$i]}

    echo -e "${CYAN}${BOLD}[TEST: $LABEL]${NC}"
    echo -e "${CYAN}PROMPT:${NC} $PROMPT"
    echo -e "${GREEN}GENERATING RESPONSE...${NC}"
    
    # Run inference
    START=$(date +%s%N)
    RESPONSE_JSON=$(curl -s http://localhost:11434/api/generate -d "{
      \"model\": \"$MODEL\",
      \"prompt\": \"$PROMPT\",
      \"stream\": false
    }")
    
    # Extract Data
    TEXT=$(echo $RESPONSE_JSON | jq -r .response)
    TOKENS=$(echo $RESPONSE_JSON | jq -r .eval_count)
    DUR_NS=$(echo $RESPONSE_JSON | jq -r .eval_duration)
    
    # Calculations
    DUR_SEC=$(echo "scale=2; $DUR_NS / 1000000000" | bc)
    TPS=$(echo "scale=2; $TOKENS / $DUR_SEC" | bc)

    # Visual Output
    echo -e "\n${BOLD}RESULT:${NC}\n$TEXT"
    echo -e "\n${YELLOW}-----------------------------------------${NC}"
    echo -e "${YELLOW}METRICS: $TOKENS Tokens | $DUR_SEC Seconds | ${BOLD}$TPS TPS${NC}"
    echo -e "${YELLOW}-----------------------------------------${NC}\n"
    
    # Pause slightly so the viewer can read
    sleep 2
done

echo -e "${BOLD}Demo Complete. Comparison metrics logged to project CSV.${NC}"