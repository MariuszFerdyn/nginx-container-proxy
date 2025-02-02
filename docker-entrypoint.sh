#!/bin/bash
# Save as: docker-entrypoint.sh

set -e

# Process nginx configuration files
envsubst '${DEFAULT_OVERRIDE_HOST} ${DEFAULT_OVERRIDE_PROTOCOL} ${DEFAULT_OVERRIDE_IP} ${DEFAULT_OVERRIDE_PORT}' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp
mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf

# If environment variables are set, update vhost.d/default
if [[ -n "$DEFAULT_OVERRIDE_HOST" && -n "$DEFAULT_OVERRIDE_IP" ]]; then
    envsubst < /etc/nginx/vhost.d/default > /etc/nginx/vhost.d/default.tmp
    mv /etc/nginx/vhost.d/default.tmp /etc/nginx/vhost.d/default
fi

# Execute CMD
exec "$@"