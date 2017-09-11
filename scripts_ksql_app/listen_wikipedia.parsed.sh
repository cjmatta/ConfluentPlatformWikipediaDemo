#!/bin/sh

docker exec confluentplatformwikipediademo_connect_1 kafka-console-consumer \
  --bootstrap-server kafka:9092 --topic wikipedia.parsed
