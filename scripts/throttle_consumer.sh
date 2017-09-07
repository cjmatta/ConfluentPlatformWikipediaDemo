#!/bin/bash

# Usage
if [[ -z "$1" ]] || [[ -z "$2" ]]; then
  echo "Usage: ./throttle_consumer.sh [id 1|2] [quota add|delete]"
  exit 1
fi

ID=$1
ACTION=$2

if [ "$ACTION" == "add" ]; then
  CONFIG="--add-config consumer_byte_rate=1024"
else
  CONFIG="--delete-config consumer_byte_rate"
fi

CONSUMER_GROUP="app"

echo "docker-compose exec kafka kafka-configs --zookeeper zookeeper:2181 --entity-type clients --entity-name consumer_app_$ID --alter $CONFIG"
docker-compose exec kafka kafka-configs --zookeeper zookeeper:2181 --entity-type clients --entity-name consumer_app_$ID --alter $CONFIG

echo "docker-compose exec kafka kafka-configs --zookeeper zookeeper:2181 --entity-type clients --describe"
docker-compose exec kafka kafka-configs --zookeeper zookeeper:2181 --entity-type clients --describe

echo "docker-compose exec kafka kafka-consumer-groups --bootstrap-server kafka:9092 --describe --group $CONSUMER_GROUP"
docker-compose exec kafka kafka-consumer-groups --bootstrap-server kafka:9092 --describe --group $CONSUMER_GROUP

