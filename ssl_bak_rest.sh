#!/bin/sh

# This script automates the restoration of former SSL certificates and keys on ESXi hosts

cd /etc/vmware/ssl

echo "Restoring SSL backups"

cp rui.crt.bak rui.crt
cp rui.key.bak rui.key

echo "Done. Restarting services"

sh bin/services.sh restart