### Confluent Platform Wikipedia Demo
Demo streaming pipeline built around the Confluent platform, uses the following:

* [Kafka Connect](http://docs.confluent.io/3.1.1/connect/index.html)
* [Kafka Streams](http://docs.confluent.io/3.1.1/streams/index.html)
* [Confluent Schema Registry](http://docs.confluent.io/3.1.1/schema-registry/docs/index.html)
* Conflulent Control Center
* [kafka-connect-irc source connector](https://github.com/cjmatta/kafka-connect-irc)
* [kafka-connect-elasticsearch sink connectors](http://docs.confluent.io/3.1.1/connect/connect-elasticsearch/docs/elasticsearch_connector.html)
* [Elasticsearch](https://www.elastic.co/products/elasticsearch)
* [Kibana](https://www.elastic.co/products/kibana)

This demo connects to the Wikimedia Foundation's IRC channels #en.wikipedia and #en.wiktionary and streams the edits happening to Kafka via [kafka-connect-irc](https://github.com/cjmatta/kafka-connect-irc). The raw messages are transformed using a Kafka Connect Single Message Transform: [kafka-connect-transform-wikiedit](https://github.com/cjmatta/kafka-connect-transform-wikiedit) and the parsed messages are materialized into Elasticsearch for analysis by Kibana.

### Getting started
**note**: Since this repository uses submodules please clone with `--recursive`:
```
$ git clone --recursive git@github.com:cjmatta/ConfluentPlatformWikipediaDemo.git
```

1. Run `./scripts/build_connector_and_transformer.sh` to build and install the IRC connector and the transformer that will parse the Wikipedia edit messages to data.
2. Start demo with `docker-compose up -d`
3. Once everything is up and stable open [http://localhost:9021](http://localhost:9021) and you should see Control Center
4. To start streaming from IRC run `./scripts/submit_wikipedia_irc_config.sh`
5. Run `./scripts/listen_wikipedia.raw.sh` to watch the live messages from the `wikipedia.raw` topic
6. Run `./scripts/listen_wikipedia.parsed.sh` to watch the live messages from the `wikipedia.parsed` topic
7. To tell Elasticsearch what the data looks like run `./scripts/set_elasticsearch_mapping.sh`
8. Start the Elasticsearch sink: `./scripts/submit_elastic_sink_config.sh`
9. Open Kibana [http://localhost:5601/](http://localhost:5601/)
10. Check back in with Control Center to see status on messages produced/consumed

#### Kibana Dashboard
To load the included dashboard into Kibana:

1. Open Kibana [http://localhost:5601](http://localhost:5601)
2. Navigate to the management tab (gear icon) and click on "Index Patterns"
3. Configure an index pattern: specify "wikipedia.parsed" in the pattern box and ensure that "Time-field name" reads `createdat`
4. Click "Create"
5. Navigate to the "Advanced Settings" tab and set the following:
    - **timelion:es.timefield**: `createdat`
    - **timelion:es.default_index**: `wikipedia.parsed`
6. Navigate to the "Saved Objects" tab and click `import` and load the `kibana_dash.json` file.
7. Navigate to the Dashboard tab (speedometer icon) and click open -> "Wikipedia"

#### Teardown and stopping
Running `reset_demo.sh` will stop and destroy all components and clear all volumes from Docker.
