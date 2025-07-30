#!/bin/bash

# Log all output to a file and the console
exec > >(tee /var/log/user-data-diagnostics.log) 2>&1

echo "--- Starting SSM Agent Diagnostics ---"
echo "Running at: $(date)"

echo -e "\n--- 1. SSM Agent Service Status ---"
# Check the status of the snap-installed ssm agent
systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service || echo "Failed to get SSM service status."

echo -e "\n--- 2. Running SSM Processes ---"
# Grep for ssm, excluding the grep process itself
ps aux | grep -i '[s]sm' || echo "No SSM agent processes were found running."

echo -e "\n--- 3. DNS Resolution Test ---"
echo "Attempting to resolve ssm.us-east-1.amazonaws.com..."
getent hosts ssm.us-east-1.amazonaws.com || echo "DNS resolution FAILED."

echo -e "\n--- 4. Network Connectivity Test ---"
echo "Attempting TCP connection to ssm.us-east-1.amazonaws.com:443"
# The -z flag scans for listening daemons, -v is for verbose. Timeout of 5 seconds.
nc -z -v ssm.us-east-1.amazonaws.com 443

echo -e "\n--- Diagnostics Complete ---"