#!/bin/bash

set -e

sudo amazon-linux-extras enable postgresql14
sudo yum clean metadata

POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

echo "Installing PostgreSQL..."
sudo yum install -y postgresql postgresql-server

echo "Configuring PostgreSQL to start on boot..."
sudo postgresql-setup --initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql

sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '${POSTGRES_PASSWORD}';"
sudo -u postgres psql -c "CREATE DATABASE flinkdb;"

sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /var/lib/pgsql/data/postgresql.conf

echo "host    all             all             0.0.0.0/0               md5" | sudo tee -a /var/lib/pgsql/data/pg_hba.conf

sudo systemctl restart postgresql

echo "PostgreSQL setup is complete!"
