#!/bin/sh

vault server -dev -dev-root-token-id=root -dev-plugin-dir=/opt/vault_plugins -dev-listen-address=0.0.0.0:8300 &
VAULT_PID=$!

echo "Waiting for Vault to start..."
until vault status > /dev/null 2>&1; do
    sleep 1
done
echo "Vault started successfully"

export VAULT_ADDR='http://127.0.0.1:8300'
export VAULT_TOKEN=root

sleep 1

PLUGIN_SHA256=$(sha256sum /opt/vault_plugins/transiteth | cut -d' ' -f1)
echo "Plugin SHA256: $PLUGIN_SHA256"


echo "Registering plugin..."
vault write sys/plugins/catalog/secrets/transiteth sha_256="$PLUGIN_SHA256" command="transiteth"
echo "Plugin registered successfully"

echo "Enabling transiteth engine..."
vault secrets enable -path=transiteth -plugin-name=transiteth plugin
echo "Transiteth engine enabled successfully"

echo "Enabling totp engine..."
vault secrets enable -path=totp totp
echo "Totp engine enabled successfully"

wait $VAULT_PID 