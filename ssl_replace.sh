#!/bin/bash

#This script automates the replacement/renewal of SSL certificates on ESXi hosts

#Get the name of the host receiving a ne SSL certificate
echo "Host name: "
read hostName

#Find the domain of the host
echo "domain: "
read domain

#Break the domain name into its parts
IFS='.'
read -a parts <<< "$domain"
dom=${parts[0]}
last=${parts[1]}

#Enter host password for SSH
echo "Password: "
read -s passWd

#Certify the correct name for the CA file and RSA key file
echo "Key file name: "
keyFile=${hostName}-rsa.key
echo "$keyFile"
echo "Certificate file name: "
certFile=${hostName}_${dom}_${last}.pem
echo "$certFile"

#SCP the certificate and rsa key file into the host 'tmp' folder, then SSH into the host to backup the old certificate and replace it
sshpass -p $passWd scp -P 22 $certFile $keyFile root@${hostName}.${domain}:~/tmp/
sshpass -p $passWd ssh -tt root@${hostName}.${domain} << EOF
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