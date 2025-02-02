#!/bin/bash
# Save as: docker-entrypoint.sh

set -e

# Process default configuration
envsubst '${DEFAULT_OVERRIDE_HOST} ${DEFAULT_OVERRIDE_PROTOCOL} ${DEFAULT_OVERRIDE_IP} ${DEFAULT_OVERRIDE_PORT}' \
    < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Function to create vhost configuration
create_vhost_config() {
    local num=$1
    local vhost_var="VHOST${num}"
    local override_var="VHOST${num}_OVERRIDE"
    local port_var="VHOST${num}_OVERRIDE_PORT"
    local protocol_var="VHOST${num}_OVERRIDE_PROTOCOL"
    local ip_var="VHOST${num}_OVERRIDE_IP"
    
    # Check if this vhost is configured
    if [[ -n "${!vhost_var}" ]]; then
        export VHOST="${!vhost_var}"
        export OVERRIDE="${!override_var}"
        export PORT="${!port_var}"
        export PROTOCOL="${!protocol_var}"
        export IP="${!ip_var}"
        
        envsubst '${VHOST} ${OVERRIDE} ${PORT} ${PROTOCOL} ${IP}' \
            < /etc/nginx/conf.d/vhost.conf.template \
            > "/etc/nginx/conf.d/vhost_${num}.conf"
        
        echo "Created configuration for ${VHOST}"
    fi
}

# Process vhost configurations (supports up to 10 vhosts)
for i in {1..10}; do
    create_vhost_config $i
done

# Execute CMD
exec "$@"