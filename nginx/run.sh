#!/bin/sh

# since nginx doesn't support environment variable substitution, we have to replace them ourselves

sed -i "/server_name /c\server_name ${SERVER_NAMES};" /etc/nginx/nginx.conf

nginx -g "daemon off;"