#!/bin/bash

docker exec confluentplatformwikipediademo_connect_1 kafka-avro-console-consumer \
  --property schema.registry.url=http://schemaregistry:8081 \
