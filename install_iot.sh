#!/bin/bash

# Crear carpeta general y subcarpetas
mkdir -p ~/iot/{nodered,grafana,influxdb,mariadb,portainer,adminer,mosquitto}

# Instalar Docker
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Crear archivo docker-compose.yml
cat <<EOF > ~/iot/docker-compose.yml
version: '3.7'

services:
  mosquitto:
    image: eclipse-mosquitto
    ports:
      - "1883:1883"
      - "9001:9001"
    volumes:
      - ~/iot/mosquitto:/mosquitto/config
    environment:
      - MQTT_USER=admin
      - MQTT_PASSWORD=admin

  nodered:
    image: nodered/node-red
    ports:
      - "1880:1880"
    environment:
      - NODE_RED_USERNAME=admin
      - NODE_RED_PASSWORD=admin
    volumes:
      - ~/iot/nodered:/data

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - ~/iot/grafana:/var/lib/grafana

  influxdb:
    image: influxdb
    ports:
      - "8086:8086"
    environment:
      - INFLUXDB_ADMIN_USER=admin
      - INFLUXDB_ADMIN_PASSWORD=admin
    volumes:
      - ~/iot/influxdb:/var/lib/influxdb

  mariadb:
    image: mariadb
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=admin
      - MYSQL_DATABASE=iot
      - MYSQL_USER=admin
      - MYSQL_PASSWORD=admin
    volumes:
      - ~/iot/mariadb:/var/lib/mysql

  portainer:
    image: portainer/portainer-ce
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ~/iot/portainer:/data

  adminer:
    image: adminer
    ports:
      - "8080:8080"
    environment:
      - ADMINER_DEFAULT_SERVER=mariadb

volumes:
  mosquitto:
  nodered:
  grafana:
  influxdb:
  mariadb:
  portainer:
  adminer:
EOF

# Iniciar Docker Compose
cd ~/iot
sudo docker-compose up -d
