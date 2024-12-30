#!/bin/bash
# bcc setup
sudo yum install python -y
sudo yum install bcc -y
sudo -s
export PATH=$PATH:/usr/share/bcc/tools/

# download sidecar
sudo aws s3 cp s3://$2/sidecar/config.json ./sidecar/config.json
sudo aws s3 cp s3://$2/sidecar/sidecar-service-1.0.0 ./sidecar/sidecar-service-1.0.0

cd sidecar
sudo chmod 744 sidecar-service-1.0.0
sudo chmod 744 config.json
sudo ./sidecar-service-1.0.0 "$1:9092" $(ec2-metadata --instance-id | cut -d' ' -f2-) &

wget https://www.python.org/ftp/python/3.10.4/Python-3.10.4.tgz