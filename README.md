# nginx-container-proxy
Nginx-Container-Proxy is a powerful and flexible solution for managing web applications and services using Nginx as a reverse proxy. The standout feature of this project is its ability to configure Nginx through environment variables. This approach allows for dynamic configuration changes without the need to modify static configuration files, making it easier to adapt to different environments (development, staging, production) and deployment scenarios. Easy to use for Azure Container Apps and Azure Web Services.

# Build the conatiner or download
```
docker build -t nginx-container-proxy .
```
# Run The container
```
docker run -p 80:80 DEFAULT_OVERRIDE_HOST=fast-sms.net -e DEFAULT_OVERRIDE_PORT=80 -e DEFAULT_OVERRIDE_PROTOCOL=http -e DEFAULT_OVERRIDE_IP=93.157.100.46 --name nginx-container-proxy hnginx-container-proxy
```

# Test the port forwarder

## Telnet to the port
```
curl http://localhost
```
The expected outputs in this example:
```
curl http://localhost
curl: (52) Empty reply from server
curl https://localhost
curl: (35) error:0A000410:SSL routines::sslv3 alert handshake failure
```
## Debug in case of TCPDUMP
```
docker exec -it port-forwarder /bin/bash
tcpdump
```

