#!/bin/bash

sudo yum install java-11-amazon-corretto-devel -y

sudo wget https://archive.apache.org/dist/kafka/3.6.0/kafka_2.12-3.6.0.tgz

sudo tar xzf kafka_2.12-3.6.0.tgz

sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
sudo yum install git -y

export IP_ADDRS=$(hostname -I | awk '{print $1}')

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

sudo mkdir "opt"
sudo mv -f kafka_2.12-3.6.0 opt
sudo ln -s kafka_2.12-3.6.0 opt/kafka

cat <<EOT >> opt/kafka/config/zookeeper.properties
dataDir=/tmp/zookeeper
clientPort=2181
maxClientCnxns=0
admin.enableServer=false
EOT

cat <<EOT >> opt/kafka/config/server.properties
broker.id=0
num.network.threads=10
num.io.threads=20
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/tmp/kafka-logs
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=3
log.retention.check.interval.ms=300000
zookeeper.connect=localhost:2181
zookeeper.connection.timeout.ms=18000
listeners=PLAINTEXT://:9092
advertised.listeners=PLAINTEXT://$IP_ADDRS:9092
EOT

sudo sh opt/kafka/bin/zookeeper-server-start.sh -daemon /opt/kafka/config/zookeeper.properties

sleep 15

sudo sh opt/kafka/bin/kafka-server-start.sh -daemon /opt/kafka/config/server.properties

sleep 15

mkdir app

sudo aws s3 cp s3://${s3_name}/loader/loader ./app/loader

export BUCKET_NAME=${s3_name}
export REGION=${region}

export TOPIC_NAME="flink-demo-topic"
export EVENTS_NUM="100000"

cd app

mkdir datasets

chmod 777 loader
./loader