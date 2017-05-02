#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"

PARENT=$(dirname $DIR)

DOCKER_PROJECT=$(basename $(echo "$PARENT" | tr '[:upper:]' '[:lower:]'))

docker run --rm --network ${DOCKER_PROJECT}_default confluentinc/cp-kafka:latest \
    kafka-topics --zookeeper zookeeper:2181 --topic wikipedia.parsed --create --replication-factor 1 --partitions 6

docker run --rm --network ${DOCKER_PROJECT}_default confluentinc/cp-kafka:latest \
    kafka-topics --zookeeper zookeeper:2181 --topic wikipedia.failed --create --replication-factor 1 --partitions 6

