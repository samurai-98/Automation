#!/bin/bash

#This script automates the replacement/renewal of SSL certificates on ESXi hosts

echo "Host name: "
read hostName
echo "Key file name: "
read keyFile
echo "Certificate file name: "
read certFile
scp -P 22 $certFile $keyFile root@$hostName:~/tmp/
ssh -tt root@$hostName << EOF
cd /etc/vmware/ssl
cp rui.crt rui.crt.bak
cp rui.key rui.key.bak
cp /tmp/$certFile rui.crt
yes
cp /tmp/$keyFile rui.key
yes
exit
EOF
echo "Done"