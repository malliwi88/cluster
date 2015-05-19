#!/bin/bash
# Example: ./build.sh v2.0.1 my_registry

# Clone registry repo
git clone https://github.com/docker/distribution.git
cd distribution
git checkout $1
cd ..

# Create a self signed certificate for the registry
openssl req \
  -newkey rsa:2048 -nodes -keyout patch/certs/registry.pem \
  -x509 -days 365 -out patch/certs/registry.crt
  
# Set custom files
cp -Rv patch/* distribution/.

# Build custom image
cd distribution
docker build -t $2 .
cd ..

# Cleanup
rm -rf distribution

# Run registry
echo "Done! Image name is: $2"