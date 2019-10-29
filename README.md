# Unify cloudkey selfsign SSL certificate
Shell script to generate selfsign SSL certificate for Unifi Cloudkey. The script backup old SSL certificates and generate new one for nginx and tomcat.

# How to use

First login to Unifi Cloudkey via ssh. Copy create-certificate.sh and cloudkey.cnf.dist to /root.
Rename cloudkey.cnf.dist to cloudkey.cnf and replace all config entries to your own credentials. Important is the entry for your Domain (unifi.example.com).

Set shell script executable:

`chmod g+x ./create-certificate.sh`

After this you can execute script:

`./create-certificate.sh`

Last step is to import the certificate `/etc/ssl/private/cloudkey.crt` to your keychain. And trust the certificate. 

Have fun 😉

