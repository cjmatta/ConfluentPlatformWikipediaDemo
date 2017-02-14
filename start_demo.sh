#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

echo "Starting Zookeeper and Kafka"
echo
docker-compose up -d zookeeper kafka-1 kafka-2

sleep 15

$DIR/scripts/create_wikipedia_topics.sh

echo "Waiting for startup..."
sleep 15

echo "Starting Connect, Schema Registry, Control Center, Streams App, Kibana and Elasticsearch"
docker-compose up -d wikipediachangesmonitor kibana control_center

