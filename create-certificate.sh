#!/bin/sh

CURRENT_TIME=$(date "+%Y.%m.%d-%H.%M.%S")

PATH_CERT="/etc/ssl/private"

# Backup
echo "### Backup"
mkdir -p /root/backup/$CURRENT_TIME/keystore
mkdir -p /root/backup/$CURRENT_TIME/ssl
cp /usr/lib/unifi/data/keystore /root/backup/$CURRENT_TIME/keystore
cp -r $PATH_CERT/* /root/backup/$CURRENT_TIME/ssl

# Gernerate Pass key
echo "### Gernerate Pass key"
openssl genrsa \
  -des3 \
  -passout pass:mypasswd \
  -out server.pass.key 2048

# Gernerate key file
echo "### Gernerate key file"
openssl rsa \
  -passin pass:mypasswd \
  -in server.pass.key \
  -out $PATH_CERT/cloudkey.key

# Gernerate cert
echo "### Gernerate cert"
openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout $PATH_CERT/cloudkey.key \
  -out $PATH_CERT/cloudkey.crt \
  -config cloudkey.cnf \
  -sha256

# Convert to p12
echo "### Convert to p12"
openssl pkcs12 \
  -export \
  -in $PATH_CERT/cloudkey.crt \
  -inkey $PATH_CERT/cloudkey.key \
  -out cloudkey.p12 \
  -name unifi \
  -certfile $PATH_CERT/cloudkey.crt \
  -password pass:aircontrolenterprise

# Generate keystore
echo "### Generate keystore"
keytool \
  -importkeystore \
  -deststorepass aircontrolenterprise \
  -destkeypass aircontrolenterprise \
  -destkeystore /usr/lib/unifi/data/keystore \
  -srckeystore cloudkey.p12 \
  -srcstoretype pkcs12 \
  -srcstorepass aircontrolenterprise \
  -alias unifi
  
# Cleanup
echo "### Cleanup"
rm server.pass.key cloudkey.p12

# Backup new certs
echo "### Backup new certs"
tar cf $PATH_CERT/cert.tar $PATH_CERT/cloudkey.crt $PATH_CERT/cloudkey.key $PATH_CERT/unifi.keystore.jks

# Set permissions
echo "### Set permissions"
chown root:ssl-cert $PATH_CERT/cloudkey.crt $PATH_CERT/cloudkey.key $PATH_CERT/unifi.keystore.jks $PATH_CERT/cert.tar
chmod 640 $PATH_CERT/cloudkey.crt $PATH_CERT/cloudkey.key $PATH_CERT/unifi.keystore.jks $PATH_CERT/cert.tar 

# Restart webserver
echo "### Restart webserver"
service nginx restart

# Restart unifi
echo "### Restart unifi"
service unifi restart
