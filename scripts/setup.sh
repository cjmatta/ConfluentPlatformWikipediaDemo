#!/bin/bash

echo -e "\nRename the cluster with the following commands from your host machine:"
curl -X PATCH  -H "Content-Type: application/merge-patch+json" -d '{"displayName":"Kafka East"}' http://localhost:9021/2.0/clusters/kafka/$(curl -X get http://localhost:9021/2.0/clusters/kafka/ | jq --raw-output .[0].clusterId)
# If you don't have `jq`
#curl -X PATCH  -H "Content-Type: application/merge-patch+json" -d '{"displayName":"Kafka East"}' http://localhost:9021/2.0/clusters/kafka/$(curl -X get http://localhost:9021/2.0/clusters/kafka/ | awk -v FS="(clusterId\":\"|\",\"displayName)" '{print $2}' )

echo -e "\nStart streaming from IRC, source connector:"
./scripts/submit_wikipedia_irc_config.sh

echo -e "\nTell Elasticsearch what the data looks like:"
./scripts/set_elasticsearch_mapping.sh

echo -e "\nStart sending data to Elasticsearch, sink connector:"
./scripts/submit_elastic_sink_config.sh

echo -e "\nConfigure Kibana settings:"
./scripts/configure_kibana_dashboard.sh
