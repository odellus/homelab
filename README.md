# homelab

TO START:

```bash
docker compose pull
```


```bash
docker compose up db
```

watch this and wait to see when it is ready, then ctrl + C to stop.

Then do this

## db
```bash
docker compose up -d db
```

This starts it in daemon mode in the background

Now you can run these commands
```bash
# Create databases for your services on the postgres instance
docker compose exec db psql -U postgres -c "CREATE DATABASE phoenix;"
docker compose exec db psql -U postgres -c "CREATE DATABASE litellm;"
docker compose exec db psql -U postgres -c "CREATE DATABASE openwebui;"
```


## phoenix
now do this

```bash
docker compose up -d phoenix
```

go log in to `http://localhost:6006` with username `admin@localhost` and password `admin` and set a new password for the account.

Go to profile and create a new api key. Call it whatever you want. I call it litellm.

Save to the .env file here as PHOENIX_API_KEY.

## litellm

Ready for this step
```bash
docker compose up -d litellm
```

I watched it for a while. You might not care to. Should Just Work after dbs are created.


I watched the logs for everything in the container plugin for vs code. You might like something else. To each their own.


## searxng

```bash
docker compose up -d searxng
```

# open-webui

```bash
docker compose up -d open-webui
```


## Connect litellm
Admin Panel -> Settings -> Connections -> OpenAI API
URL = http://litellm:4000/v1

Turn off ollama while you're there. We set up ollama through litellm so we can instrument openwebui (and whatever comes next/whatever we plug into it).


## Connect searxng
Admin Panel -> Settings -> Web Search
Web Search Engine = searxng
Searxng Query URL = http://searxng:8080/search

I like to put a bunch of results in there so I bump up search result count to 20 and concurrent requests up to 10 since we are hosting our own searxng we don't have to play nice. You also have to enable Web Search here. That's the only way to get it to work.

An alternative to this is to give you agent an MCP with a searxng search tool, which I've done. Their search is better than just a simple search tool call. Definitely value in it.


# Digital Ocean and Big ICANN
Create an el cheapo

# Caddy

Input: 
```bash
cat caddy/etc/caddy/Caddyfile
```
Output:
```
{
	email me@advanced-eschatonics.com
}

advanced-eschatonics.com, www.advanced-eschatonics.com, blog.advanced-eschatonics.com {
        reverse_proxy http://10.8.0.2:MYSTMD_PORT
}

code.advanced-eschatonics.com {
        reverse_proxy http://10.8.0.2:CODE_SERVER_PORT
}


openwebui.advanced-eschatonics.com {
        reverse_proxy http://10.8.0.2:OPEN_WEBUI_PORT
}

phoenix.advanced-eschatonics.com {
        reverse_proxy http://10.8.0.2:PHOENIX_PORT
}

pds.advanced-eschatonics.com {
	reverse_proxy http://localhost:PDS_PORT
}
```



# WIREGUARD


## Droplet
Put this in in `/etc/wireguard/wg0.conf`
```
[Interface]
Address = 10.8.0.1/24
PrivateKey = # DROPLET'S PRIVATE KEY ~/.ssh/id_ed26619
ListenPort = # PICK ONE OR LOOK IT UP
# Let the OS forward traffic (needed later for DNAT)
PostUp   = sysctl -w net.ipv4.ip_forward=1
PostDown = sysctl -w net.ipv4.ip_forward=0

[Peer]
PublicKey = # USER'S PUBLIC KEY ~/.ssh/id_ed26619.pub on local machine
AllowedIPs = 10.8.0.2/32
PersistentKeepalive = 25

```

## Local

```
[sudo] password for thomas: 
[Interface]
Address = 10.8.0.2/24
PrivateKey = # PRIVATE KEY OF USER from ~/.ssh/id_ed25519 on local machine

[Peer]
PublicKey = # PUBLIC KEY OF DROPLET from ~/.ssh/id_ed25519.pub on droplet
Endpoint = DROPLET_PUBLIC_IP:DROPLET_LISTEN_PORT # FIND YOUR DROPLET'S PUBLIC IP
AllowedIPs = 10.8.0.1/32    # tunnel traffic only
PersistentKeepalive = 25
```

# code-server

okay now for the part where we install `code-server` with ubuntu 22.04

```bash
curl -fsSL https://code-server.dev/install.sh | sh
# Do this part
# To have systemd start code-server now and restart on boot:
sudo systemctl enable --now code-server@$USER
```
configurations for code-server are in `~/.config/code-server/config.yaml`. Make sure `$CODE_SERVER_PORT` matches your port in your config.

