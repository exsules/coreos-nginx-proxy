#!/bin/bash

set -eo pipefail

export ETCD_PORT=${ETCD_PORT:-2379}
export ETCD_HOST=${ETCD_HOST:-172.17.42.1}
export ETCD=$ETCD_HOST:$ETCD_PORT
export CONFD=/usr/local/bin/confd
export TOML=/etc/confd/conf.d/nginx.toml

echo "[nginx] booting container. ETCD: $ETCD"

until ${CONFD} -onetime -node ${ETCD} -config-file ${TOML}; do
  echo "[nginx] waiting for confd to create intitial nginx configuration."
  sleep 5
done

${CONFD} -interval 10 -node ${ETCD} -config-file ${TOML} &
echo "[nginx] confd is now monitoring etcd for changes..."

# Start the Haproxy service using the generated config
echo "[nginx] starting nginx service..."
chown nginx:nginx /var/lib/nginx -R
/usr/sbin/nginx -g 'daemon off;'

tail -f /var/log/nginx/access.log
