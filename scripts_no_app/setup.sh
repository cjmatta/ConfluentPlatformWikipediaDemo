#!/bin/bash

echo -e "\nRename the cluster with the following commands from your host machine:"
curl -X PATCH  -H "Content-Type: application/merge-patch+json" -d '{"displayName":"Kafka Raleigh"}' http://localhost:9021/2.0/clusters/kafka/$(curl -X get http://localhost:9021/2.0/clusters/kafka/ | jq --raw-output .[0].clusterId)
# If you don't have `jq`
#curl -X PATCH  -H "Content-Type: application/merge-patch+json" -d '{"displayName":"Kafka Raleigh"}' http://localhost:9021/2.0/clusters/kafka/$(curl -X get http://localhost:9021/2.0/clusters/kafka/ | awk -v FS="(clusterId\":\"|\",\"displayName)" '{print $2}' )

echo -e "\nStart streaming from IRC, source connector:"
./scripts_no_app/submit_wikipedia_irc_config.sh

echo -e "\nTell Elasticsearch what the data looks like:"
./scripts_no_app/set_elasticsearch_mapping.sh

echo -e "\nStart sending data to Elasticsearch, sink connector:"
./scripts_no_app/submit_elastic_sink_config.sh

echo -e "\nConfigure Kibana settings:"
./scripts_no_app/configure_kibana_dashboard.sh
