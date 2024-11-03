#!/bin/bash
set -e
# Detect the current Git branch
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

# Define server URLs based on the branch
if [[ "$BRANCH_NAME" == "main" ]]; then
  THEWELL_GPT_SERVER_URL="http://thewell-gpt-lb-101888234.ap-northeast-2.elb.amazonaws.com"
else
  LOCAL_IP=$(ifconfig | grep -E 'inet (172\.)' | awk '{print $2}' | head -n 1)
  if [ -z "$LOCAL_IP" ]; then
      echo "No valid local IP address found in the 172.x.x.x range. Defaulting to localhost."
      LOCAL_IP="127.0.0.1"
  fi
  THEWELL_GPT_SERVER_URL="http://$LOCAL_IP:8000"
fi

# Export the SERVER_URL as an environment variable
export THEWELL_GPT_SERVER_URL

# Write the server URL to a Dart file
echo "const String serverUrl = '$THEWELL_GPT_SERVER_URL';" > lib/util/server_config.dart