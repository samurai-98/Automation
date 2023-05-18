#!/bin/bash

# This script automates the restoration of former SSL certificates and keys on ESXi hosts
echo "Host name: "
read host

echo "Domain: "
read domain

echo "Password: "
read -s passWd

echo "Restoring SSL backups"

sshpass -p $passWd ssh -tt -o StrictHostKeyChecking=no root@${host}.${domain} << EOF
cd /etc/vmware/ssl
cp rui.crt.bak rui.crt
cp rui.key.bak rui.key
exit
EOF

echo "Done. Reboot and reconnect host to apply changes"
