# nginx-container-proxy
Nginx-Container-Proxy is a powerful and flexible solution for managing web applications and services using Nginx as a reverse proxy. The standout feature of this project is its ability to configure Nginx through environment variables. This approach allows for dynamic configuration changes without the need to modify static configuration files, making it easier to adapt to different environments (development, staging, production) and deployment scenarios. Easy to use for Azure Container Apps and Azure Web Services.

# Build the conatiner or download
```
docker build -t nginx-container-proxy .
docker pull mafamafa/nginx-container-proxy:202502021555
```
# Run The container
## With default OVERRIDE HOST
```
docker run -p 80:80 -e DEFAULT_OVERRIDE_HOST=fast-sms.net -e DEFAULT_OVERRIDE_PORT=80 -e DEFAULT_OVERRIDE_PROTOCOL=http -e DEFAULT_OVERRIDE_IP=93.157.100.46 -e WEBHOOKAFTERSTART=http://fast-sms.net/a.txt --name nginx-container-proxy nginx-container-proxy
```
## With default OVERRIDE HOST and 2 additionals VHOSTS
```
docker run -p 80:80 -e DEFAULT_OVERRIDE_HOST=fast-sms.net -e DEFAULT_OVERRIDE_PORT=80 -e DEFAULT_OVERRIDE_PROTOCOL=http -e DEFAULT_OVERRIDE_IP=93.157.100.46 -e VHOST1=emailmarketing.fast-sms.net -e VHOST1_OVERRIDE=emailmarketing.fast-sms.net -e VHOST1_OVERRIDE_PORT=80 -e VHOST1_OVERRIDE_PROTOCOL=http -e VHOST1_OVERRIDE_IP=93.157.100.46 -e VHOST2=openinternet.h.com.pl -e VHOST2_OVERRIDE=openinternet.h.com.pl -e VHOST2_OVERRIDE_PORT=80 -e VHOST2_OVERRIDE_PROTOCOL=http -e VHOST2_OVERRIDE_IP=93.157.100.46 -e WEBHOOKAFTERSTART=http://fast-sms.net/a.txt --name nginx-container-proxy nginx-container-proxy
```
## Only with VHOSTS configuration
```
docker run -p 80:80 -e VHOST1=emailmarketing.fast-sms.net -e VHOST1_OVERRIDE=emailmarketing.fast-sms.net -e VHOST1_OVERRIDE_PORT=80 -e VHOST1_OVERRIDE_PROTOCOL=http -e VHOST1_OVERRIDE_IP=93.157.100.46 -e VHOST2=openinternet.h.com.pl -e VHOST2_OVERRIDE=openinternet.h.com.pl -e VHOST2_OVERRIDE_PORT=80 -e VHOST2_OVERRIDE_PROTOCOL=http -e VHOST2_OVERRIDE_IP=93.157.100.46 -e WEBHOOKAFTERSTART=http://fast-sms.net/a.txt --name nginx-container-proxy nginx-container-proxy
```
WEBHOOKAFTERSTART informs that container started and it is optional.

# Test the proxy
```
curl http://localhost
```
# Debug
```
# Check nginx config
docker exec nginx-container-proxy nginx -t

# View logs
docker logs nginx-container-proxy

# Follow logs
docker logs -f nginx-container-proxy
# View generated configs
docker exec nginx-container-proxy ls -la /etc/nginx/conf.d/
docker exec nginx-container-proxy cat /etc/nginx/conf.d/vhost_1.conf
```

