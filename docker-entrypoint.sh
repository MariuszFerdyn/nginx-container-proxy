#!/bin/bash
set -e

# Function to display configuration file content
display_config() {
    local file=$1
    if [ -f "$file" ]; then
        echo "==================================================="
        echo "Displaying content of: $file"
        echo "==================================================="
        cat "$file"
        echo "==================================================="
        echo ""
    fi
}

# Function to setup default server configuration
setup_default_config() {
    # Check if any of the DEFAULT_* variables are set
    if [[ -n "$DEFAULT_OVERRIDE_HOST" || -n "$DEFAULT_OVERRIDE_PORT" || -n "$DEFAULT_OVERRIDE_PROTOCOL" || -n "$DEFAULT_OVERRIDE_IP" ]]; then
        # Verify all required DEFAULT variables are present
        if [[ -z "$DEFAULT_OVERRIDE_HOST" ]] || [[ -z "$DEFAULT_OVERRIDE_PORT" ]] || [[ -z "$DEFAULT_OVERRIDE_PROTOCOL" ]] || [[ -z "$DEFAULT_OVERRIDE_IP" ]]; then
            echo "Warning: Some DEFAULT_* variables are defined but missing required variables."
            echo "Required variables for DEFAULT configuration:"
            echo "- DEFAULT_OVERRIDE_HOST: ${DEFAULT_OVERRIDE_HOST:-missing}"
            echo "- DEFAULT_OVERRIDE_PORT: ${DEFAULT_OVERRIDE_PORT:-missing}"
            echo "- DEFAULT_OVERRIDE_PROTOCOL: ${DEFAULT_OVERRIDE_PROTOCOL:-missing}"
            echo "- DEFAULT_OVERRIDE_IP: ${DEFAULT_OVERRIDE_IP:-missing}"
            echo "Setting up catch-all server instead..."
            cp /etc/nginx/conf.d/default_catchall.conf.template /etc/nginx/conf.d/default.conf
            return 1
        fi

        echo "Setting up default server with proxy configuration..."
        envsubst '${DEFAULT_OVERRIDE_HOST} ${DEFAULT_OVERRIDE_PROTOCOL} ${DEFAULT_OVERRIDE_IP} ${DEFAULT_OVERRIDE_PORT}' \
            < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
    else
        echo "No DEFAULT_* variables set. Setting up catch-all server..."
        cp /etc/nginx/conf.d/default_catchall.conf.template /etc/nginx/conf.d/default.conf
    fi
}

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
        # Verify all required variables are present
        if [[ -z "${!override_var}" ]] || [[ -z "${!port_var}" ]] || [[ -z "${!protocol_var}" ]] || [[ -z "${!ip_var}" ]]; then
            echo "Warning: VHOST${num} is defined but missing required variables. Skipping..."
            echo "Required variables for VHOST${num}:"
            echo "- ${override_var}: ${!override_var:-missing}"
            echo "- ${port_var}: ${!port_var:-missing}"
            echo "- ${protocol_var}: ${!protocol_var:-missing}"
            echo "- ${ip_var}: ${!ip_var:-missing}"
            return 1
        fi

        export VHOST="${!vhost_var}"
        export OVERRIDE="${!override_var}"
        export PORT="${!port_var}"
        export PROTOCOL="${!protocol_var}"
        export IP="${!ip_var}"
        
        echo "Creating configuration for ${VHOST}..."
        envsubst '${VHOST} ${OVERRIDE} ${PORT} ${PROTOCOL} ${IP}' \
            < /etc/nginx/conf.d/vhost.conf.template \
            > "/etc/nginx/conf.d/vhost_${num}.conf"
        
        echo "Successfully created configuration for ${VHOST}"
    fi
}

# Setup default configuration
setup_default_config

# Process vhost configurations
for i in {1..10}; do
    create_vhost_config $i
done

echo ""
echo "Displaying generated configuration files:"
echo ""

# Display main nginx configuration
display_config "/etc/nginx/nginx.conf"

# Display default server configuration
display_config "/etc/nginx/conf.d/default.conf"

# Display any generated vhost configurations
for i in {1..10}; do
    display_config "/etc/nginx/conf.d/vhost_${i}.conf"
done

# Display vhost.d/default file
display_config "/etc/nginx/vhost.d/default"

# Test nginx configuration
echo "Testing nginx configuration..."
nginx -t

# Start nginx in background
nginx

# Wait for nginx to start
sleep 2

# Send webhook notification if URL is provided
if [ -n "${WEBHOOKAFTERSTART}" ]; then
    echo -e "\nSending webhook notification to $WEBHOOKAFTERSTART..."
    webhook_response=$(curl -s -X POST "$WEBHOOKAFTERSTART" -H "Content-Type: application/json" -d "{\"status\":\"container_started\", \"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}")
    echo "Webhook response: $webhook_response"
fi

# Stop nginx as we'll restart it in foreground
nginx -s quit
sleep 1

# Start nginx in foreground
echo "Starting nginx in foreground..."
exec nginx -g 'daemon off;'