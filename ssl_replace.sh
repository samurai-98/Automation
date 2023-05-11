#!/bin/bash

#Read the argument file as the Digicert API Key
API_KEY=$(<"$1")


#Reads the user input for the host name, domain, and password, then breaks the domain into its parts
echo "Host name: "
read host
echo "Domain name: "
read domain
echo "Password: "
read -s passWd
IFS='.'
read -a parts <<< "$domain"
dom=${parts[0]}
last=${parts[1]}

#Creates the correct .pem file name for the host CA
certFile=${host}_${dom}_${last}.pem

#Gets all orders for the host DNS and lists them in descending order based on order ID
orders=$(curl -g -X GET "https://www.digicert.com/services/v2/order/certificate?filters[common_name]=$host.$domain&sort=-order_id" -H 'Content-Type: application/json' -H "X-DC-DEVKEY: $API_KEY")

#Parses through all the order information to find the latest order ID AKA the last ordered certificate for the given host name, and outputs that order ID
IFS=':'
read -a orderParts <<< "$orders"
oNum=${orderParts[2]}
id=$(echo $oNum | tr -cd [:digit:])
echo $id

#Accesses the Digicert API to download the CA file in a .pem format for the latest SSL order
curl -o $certFile -X GET "https://www.digicert.com/services/v2/certificate/download/order/$id/format/pem_all" -H 'Content-Type: application/json' -H "X-DC-DEVKEY: $API_KEY"

#Certifies that the RSA key and CA files for the host have the right name
echo "Key file name: "
keyFile=${host}-rsa.key
echo "$keyFile"
echo "Certificate file name: "
echo "$certFile"

#Copies the CA and RSA key files into the ESXi host, then creates a backup of the old certificates and replaces the former SSL with the new one
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
