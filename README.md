### Confluent Platform Wikipedia Demo
Demo streaming pipeline built around the Confluent platform, uses the following:

* [Kafka Connect](http://docs.confluent.io/3.1.1/connect/index.html)
* [Kafka Streams](http://docs.confluent.io/3.1.1/streams/index.html)
* Conflulent Control Center
* [kafka-connect-irc source connector](https://github.com/cjmatta/kafka-connect-irc)
* [kafka-connect-elasticsearch sink connectors](http://docs.confluent.io/3.1.1/connect/connect-elasticsearch/docs/elasticsearch_connector.html)
* [Elasticsearch](https://www.elastic.co/products/elasticsearch)
* [Kibana](https://www.elastic.co/products/kibana)

This demo connects to the Wikimedia Foundation's IRC channels #en.wikipedia and #en.wiktionary and streams the edits happening to Kafka via [kafka-connect-irc](https://github.com/cjmatta/kafka-connect-irc). The raw messages are transformed using a Kafka Streams app [WikipediaChangesMonitor](https://github.com/cjmatta/WikipediaChangesMonitor) and the parsed messages are materialized into Elasticsearch for analysis by Kibana.

![Demo Drawing](https://cjmatta.github.io/ConfluentPlatformWikipediaDemo/drawing.png)

### Getting started
1. Run `docker-compose up` from the root of the project
2. Once everything is up and stable open [http://localhost:9021](http://localhost:9021) and you should see Control Center (no graphs yet!)
3. To start streaming from IRC run `./scripts/submit_wikipedia_irc_config.sh`
4. Run `./scripts/listen_wikipedia.raw.sh` to watch the live messages from the `wikipedia.raw` topic
5. Run `./scripts/listen_wikipedia.parsed.sh` to watch the live messages from the `wikipedia.parsed` topic
6. To tell Elasticsearch what the data looks like run `./scripts/set_elasticsearch_mapping.sh`
7. Start the Elasticsearch sink: `./scripts/submit_elastic_sink_config.sh`
8. Open Kibana [http://localhost:5601/](http://localhost:5601/)
9. Check back in with Control Center to see status on messages produced/consumed
