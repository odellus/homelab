#!/bin/sh

echo "Installing code-server..."
curl -fsSL https://code-server.dev/install.sh | sh
echo "WARNING!"
echo "REQUIRES SUDO!"
sudo systemctl enable --now code-server@$USER




echo "Installation of code-server finished! check ${HOME}/.config/code-server/config.yaml for configs"

echo "Installing postgres..."

docker compose up -d db

echo "Waiting a few seconds for it to wake up..."
sleep 5

echo "Creating phoenix, litellm, and openwebui tables"
docker compose exec db psql -U postgres -c "CREATE DATABASE phoenix;"
docker compose exec db psql -U postgres -c "CREATE DATABASE litellm;"
docker compose exec db psql -U postgres -c "CREATE DATABASE openwebui;"

echo "Databases created. Starting phoenix."

docker compose up -d phoenix

echo "Phoenix is going up"

echo "Brining up openwebui"

docker compose up -d open-webui

echo "Phoenix and Open-WebUI are now running on http://localhost:6006 and http://localhost:3007 respectively"

echo "Log in to http://localhost:6006 with:"
echo "username: admin@localhost"
echo "password: admin" 
echo "CHANGE YOUR PASSWORD"

echo "Go to profile and generate a PHOENIX_API_KEY"
echo "paste it into .env"

echo "run docker compose up -d litellm"

echo "enjoy instrumented openwebui"