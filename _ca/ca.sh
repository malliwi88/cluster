#!/bin/bash
# Easy to use helper to manage a simple CA and certificate creation
# Author: Ben Cessa <ben@pixative.com>

# Create a self signed root CA
function rootCA() {
  # Read data
  read -p "Root CA name: " CANAME
  read -p "Valid years: " DYEARS
  
  # Create the certificate and key
  openssl req -new -x509 -nodes -config tmpl_root.cnf \
    -days $[$DYEARS * 365] \
    -out $CANAME.crt \
    -keyout $CANAME.pem
  
  # SSH root CA key
  chmod 0600 $CANAME.pem
  ssh-keygen -yf $CANAME.pem > ${CANAME}_ssh.pub
  
  # Move files to cert storage folder
  mv $CANAME.crt certs/.
  mv $CANAME.pem certs/.
  mv ${CANAME}_ssh.pub certs/.
}

# Create an intermediate CA
function iCA() {
  # Read data
  read -p "Intermediate CA name: " CANAME
  read -p "Root CA name: " RCANAME
  read -p "Valid days: " DAYS
  
  # Create certificate request
  openssl req -new -nodes -config tmpl_client.cnf \
    -out $CANAME.csr \
    -keyout $CANAME.pem \
    -reqexts ica
  
  # Sign the request with the rootCA provided
  openssl x509 -req -in $CANAME.csr \
    -CA certs/$RCANAME.crt \
    -CAkey certs/$RCANAME.pem \
    -CAcreateserial \
    -days $DAYS \
    -extfile tmpl_client.cnf \
    -extensions ica \
    -out $CANAME.crt
  
  # Concatenate rootCA with iCA certificate
  cat $CANAME.crt certs/$RCANAME.crt > bundle.crt
  mv bundle.crt $CANAME.crt
  
  # Delete signed request and temporary serial number file
  rm $CANAME.csr
  rm certs/$RCANAME.srl
  
  # Move files to cert storage folder
  mv $CANAME.crt certs/.
  mv $CANAME.pem certs/.
}

# Generate a service client certificate
function client() {
  # Read data
  read -p "Root CA name: " CANAME
  read -p "Client certificate name: " CERT
  read -p "Valid days: " DAYS
  
  # Create certificate request
  openssl req -new -nodes -config tmpl_client.cnf \
    -out $CERT.csr \
    -keyout $CERT.pem \
    -reqexts client
  
  # Sign the request with the rootCA provided
  openssl x509 -req -in $CERT.csr \
    -CA certs/$CANAME.crt \
    -CAkey certs/$CANAME.pem \
    -CAcreateserial \
    -days $DAYS \
    -extfile tmpl_client.cnf \
    -extensions client \
    -out $CERT.crt
  
  # Concatenate rootCA with iCA certificate
  cat $CERT.crt certs/$CANAME.crt > bundle.crt
  mv bundle.crt $CERT.crt
  
  # Delete signed request and temporary serial number file
  rm $CERT.csr
  rm certs/$CANAME.srl
  
  # Move files to cert storage folder
  mv $CERT.crt certs/.
  mv $CERT.pem certs/.
}

# Generate an email protection user certificate
function email() {
  # Read data
  read -p "Root CA name: " CANAME
  read -p "Email certificate name: " CERT
  read -p "Valid days: " DAYS
  
  # Create certificate request
  openssl req -new -nodes -config tmpl_client.cnf \
    -out $CERT.csr \
    -keyout $CERT.pem \
    -reqexts email
  
  # Sign the request with the rootCA provided
  openssl x509 -req -in $CERT.csr \
    -CA certs/$CANAME.crt \
    -CAkey certs/$CANAME.pem \
    -CAcreateserial \
    -days $DAYS \
    -extfile tmpl_client.cnf \
    -extensions email \
    -out $CERT.crt
  
  # Concatenate rootCA with iCA certificate
  cat $CERT.crt certs/$CANAME.crt > bundle.crt
  mv bundle.crt $CERT.crt
  
  # Delete signed request and temporary serial number file
  rm $CERT.csr
  rm certs/$CANAME.srl
  
  # Move files to cert storage folder
  mv $CERT.crt certs/.
  mv $CERT.pem certs/.
}

# Generate a developer user certificate (code sign support)
function developer() {
  # Read data
  read -p "Root CA name: " CANAME
  read -p "Developer certificate name: " CERT
  read -p "Valid days: " DAYS
  
  # Create certificate request
  openssl req -new -nodes -config tmpl_client.cnf \
    -out $CERT.csr \
    -keyout $CERT.pem \
    -reqexts developer
  
  # Sign the request with the rootCA provided
  openssl x509 -req -in $CERT.csr \
    -CA certs/$CANAME.crt \
    -CAkey certs/$CANAME.pem \
    -CAcreateserial \
    -days $DAYS \
    -extfile tmpl_client.cnf \
    -extensions developer \
    -out $CERT.crt
  
  # Concatenate rootCA with iCA certificate
  cat $CERT.crt certs/$CANAME.crt > bundle.crt
  mv bundle.crt $CERT.crt
  
  # Delete signed request and temporary serial number file
  rm $CERT.csr
  rm certs/$CANAME.srl
  
  # Move files to cert storage folder
  mv $CERT.crt certs/.
  mv $CERT.pem certs/.
}

# Generate a SSH client access cert
function ssh-client() {
  # Read data
  read -p "Root CA name: " CANAME
  read -p "SSH certificate name: " CERT
  
  echo ""
  read -p "Key Identifier to include in the certificate: " PRIM_ID
  read -p "User principal names to include in certificate (email,username,etc): " NAMES
  read -p "Expiration (1d,5w): " EXPTIME
  read -p "Key size (bits): " BITS
  
  # Calculate a good serial for the certificate
  SERIAL=`echo -n $NAMES | openssl md5 | tr -cd [:digit:] | cut -c 1-15`
  
  # Generate a standard SSH key first
  openssl genrsa -out $CERT $BITS
  chmod 0600 $CERT
  ssh-keygen -f $CERT -y > $CERT.ssh.pub
  
  # Sign with the rootCA to create a certificate
  ssh-keygen -s certs/$CANAME.pem \
    -I $PRIM_ID \
    -n $NAMES \
    -V "+${EXPTIME}" \
    -z $SERIAL \
    $CERT.ssh.pub
  
  # Concatenate the private key in the certificate file
  cat $CERT >> ${CERT}.ssh-cert.pub
  chmod 0600 ${CERT}.ssh-cert.pub
  rm $CERT $CERT.ssh.pub
  
  # Output the new certificate data
  echo ""
  echo "Certificate Details:"
  ssh-keygen -L -f ${CERT}.ssh-cert.pub
  
  # Move files to cert storage folder
  mv ${CERT}.ssh-cert.pub certs/.
}

# Generate a SSH client access cert
function ssh-host() {
  # Read data
  read -p "Root CA name: " CANAME
  read -p "Host public key: " HPKEY
  
  echo ""
  read -p "Expiration (1d,5w): " EXPTIME
  
  # Use full hostname as key identifier to include in the certificate
  PRIM_ID=`hostname -f`
  
  # Use full and single hostnames as well as ip addresses as principals
  NAMES=`hostname -f`,`hostname -s`
  
  # Calculate a good serial for the certificate
  SERIAL=`uname -a | openssl md5 | tr -cd [:digit:] | cut -c 1-15`
  
  # Sign with the rootCA to create a certificate
  ssh-keygen -s certs/$CANAME.pem \
    -h \
    -I $PRIM_ID \
    -n $NAMES \
    -V "+${EXPTIME}" \
    -z $SERIAL \
    $HPKEY
  
  # Adjust permissions
  chmod 0600 ${HPKEY}-cert.pub
  
  # Output the new certificate data
  echo ""
  echo "Certificate Details:"
  ssh-keygen -L -f ${HPKEY}-cert.pub
}

# Check that the user enter at least one parameter
if [ $# == 0 ]; then
  echo 'You must specify a parameter'
  exit
fi

# Read the user command, default to help message
case $1 in
  'rootCA') rootCA;;
  'iCA') iCA $2;;
  'client') client;;
  'email') email;;
  'developer') developer;;
  'ssh-client') ssh-client;;
  'ssh-host') ssh-host;;
  *) echo 'Invalid command! - rootCA, iCA, client, email, developer, ssh-client, ssh-host';;
esac
