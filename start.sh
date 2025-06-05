#!/bin/sh

vault server -dev -dev-root-token-id=root -dev-plugin-dir=/opt/vault_plugins -dev-listen-address=0.0.0.0:8200 &
VAULT_PID=$!

echo "Waiting for Vault to start..."
until vault status > /dev/null 2>&1; do
    sleep 1
done
echo "Vault started successfully"

export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN=root

sleep 1

PLUGIN_SHA256=$(sha256sum /opt/vault_plugins/transiteth-plugin | cut -d' ' -f1)
echo "Plugin SHA256: $PLUGIN_SHA256"


echo "Registering plugin..."
vault write sys/plugins/catalog/secrets/transiteth-plugin sha_256="$PLUGIN_SHA256" command="transiteth-plugin"
echo "Plugin registered successfully"

echo "Enabling transiteth-plugin engine..."
vault secrets enable -path=transiteth -plugin-name=transiteth-plugin plugin
echo "Transiteth-plugin engine enabled successfully"

wait $VAULT_PID 