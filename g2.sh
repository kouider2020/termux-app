#!/bin/bash
set -e

# -------------------------------
# Step 1: Prepare public folder
# -------------------------------
mkdir -p public
# Optional: add a sample file
echo "Hello from Bash & ngrok" > public/hello.txt
echo "Another file" > public/readme.txt
cp *.apk *.sh public
# -------------------------------
# Step 2: Start Python HTTP server
# -------------------------------
echo "[*] Starting Python HTTP server on port 8080..."
cd public
nohup python3 -m http.server 8080 > ../server.log 2>&1 &
cd ..

# -------------------------------
# Step 3: Install ngrok if needed
# -------------------------------
if ! command -v ngrok &>/dev/null; then
    echo "[*] Installing ngrok..."
    sudo apt update
    sudo apt install -y curl jq
    curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
    sudo apt update && sudo apt install -y ngrok
fi

# -------------------------------
# Step 4: Start ngrok tunnel
# -------------------------------
NGROK_TOKEN="2xATPBWrqoYwjCqxDCwDSREw6ty_2GQpzV5nx9esMhcLH3UJ6"
echo "[*] Starting ngrok tunnel..."
ngrok config add-authtoken "$NGROK_TOKEN"
nohup ngrok http 8080 > ngrok.log 2>&1 &
sleep 10

# -------------------------------
# Step 5: Fetch ngrok public URL
# -------------------------------
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
echo "[*] Your ngrok URL is: $NGROK_URL"

# -------------------------------
# Step 6: Keep server alive
# -------------------------------
echo "[*] Server and ngrok tunnel will stay alive for 10 minutes..."
sleep 600
echo "[*] Done. Server stopped."
