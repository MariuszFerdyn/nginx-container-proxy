# Dockerfile
FROM nginx:alpine

# Install required packages
RUN apk add --no-cache \
    bash \
    gettext \
    dos2unix \
    tcpdump \
    curl

# Create necessary directories
RUN mkdir -p /etc/nginx/vhost.d /etc/nginx/conf.d

# Create symbolic links for logging to stdout/stderr
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Copy config files and templates
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY config/default_catchall.conf.template /etc/nginx/conf.d/default_catchall.conf.template
COPY config/vhost.conf.template /etc/nginx/conf.d/vhost.conf.template
COPY config/vhost.d/default /etc/nginx/vhost.d/default

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN dos2unix /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh


ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]