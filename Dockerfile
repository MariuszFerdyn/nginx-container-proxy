# Dockerfile
FROM nginx:alpine

# Install bash and envsubst
RUN apk add --no-cache bash gettext dos2unix

# Create necessary directories
RUN mkdir -p /etc/nginx/vhost.d

# Copy nginx configuration files
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/default.conf /etc/nginx/conf.d/default.conf
COPY config/vhost.d/default /etc/nginx/vhost.d/default

# Copy and fix entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN dos2unix /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh && \
    chown nginx:nginx /docker-entrypoint.sh

# Set environment variables with default values
ENV DEFAULT_OVERRIDE_HOST=""
ENV DEFAULT_OVERRIDE_PORT="80"
ENV DEFAULT_OVERRIDE_PROTOCOL="http"
ENV DEFAULT_OVERRIDE_IP=""

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]