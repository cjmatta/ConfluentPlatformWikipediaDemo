docker exec confluentplatformwikipediademo_connect_1 kafka-avro-console-consumer \
  --property schema.registry.url=http://schemaregistry:8081 \
  --bootstrap-server kafka:9092 --topic wikipedia.raw --new-consumer
