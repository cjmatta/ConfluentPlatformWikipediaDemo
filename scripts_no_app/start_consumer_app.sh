#!/bin/bash

docker exec confluentplatformwikipediademo_connect_1 kafka-avro-console-consumer --property schema.registry.url=http://schemaregistry:8081 --bootstrap-server kafka:9092 --topic wikipedia.parsed --consumer-property group.id=app --consumer-property client.id=consumer_app_1 --consumer-property interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor >/dev/null 2>&1 &

docker exec confluentplatformwikipediademo_connect_1 kafka-avro-console-consumer --property schema.registry.url=http://schemaregistry:8081 --bootstrap-server kafka:9092 --topic wikipedia.parsed --consumer-property group.id=app --consumer-property client.id=consumer_app_2 --consumer-property interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor >/dev/null 2>&1 &
