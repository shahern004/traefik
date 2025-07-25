#!/bin/bash
# generate-traefik-config.sh
# Generates a dynamic Traefik config for a given service

set -e

# Show usage if arguments are missing
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <name> <fqdn> <backend_url>"
  echo "Example: $0 lldap lldap.example.com http://YOUR_IP_ADDRESS:17170"
  exit 1
fi

NAME=$1
HOST=$2
BACKEND_URL=$3
OUTPUT_FILE="/etc/traefik/dynamic/${NAME}.yml"

cat <<EOF2 > "$OUTPUT_FILE"
http:
  routers:
    ${NAME}:
      rule: "Host(\`${HOST}\`)"
      entryPoints:
        - http
        - https
      service: ${NAME}
      middlewares:
        - security-headers-${NAME}

  middlewares:
    security-headers-${NAME}:
      headers:
        sslRedirect: true
        frameDeny: true
        contentTypeNosniff: true
        browserXssFilter: true

  services:
    ${NAME}:
      loadBalancer:
        servers:
          - url: "${BACKEND_URL}"
        passHostHeader: true
EOF2

echo "Traefik dynamic config written to: ${OUTPUT_FILE}"
