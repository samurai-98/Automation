#!/bin/sh

# This script automates the process for replacing SSL certificates and keys on ESXi hosts

echo "File location: "
read directory

echo "Key file name: "
read keyFile

echo "Certificate file name: "
read certFile

cd /etc/vmware/ssl
pwd

echo "Backing up former certificate and key"
cp rui.crt rui.crt.bak
cp rui.key rui.key.bak
echo "Done"

echo "Copying new certificate and key"
cp /$directory/$certFile rui.crt
cp /$directory/$keyFile rui.key
echo "Done"
