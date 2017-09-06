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

![image](drawing.png)

### Getting started
**Note**: Since this repository uses submodules please clone with `--recursive`:
```
$ git clone --recursive git@github.com:confluentinc/ConfluentPlatformWikipediaDemo.git
```

...or use git clone and then submodule init/update:
```
$ git clone git@github.com:confluentinc/ConfluentPlatformWikipediaDemo.git
$ cd ConfluentPlatformWikipediaDemo
$ git submodule init
Submodule 'kafka-connect-irc' (https://github.com/cjmatta/kafka-connect-irc) registered for path 'kafka-connect-irc'
Submodule 'kafka-connect-transform-wikiedit' (https://github.com/cjmatta/kafka-connect-transform-wikiedit) registered for path 'kafka-connect-transform-wikiedit'
$ git submodule update
```

1. Run `make clean all` to build the IRC connector and the transformer that will parse the Wikipedia edit messages to data. These are saved to `connect-plugins` path, which is a shared volume to the `connect` docker container

2. Start demo with `docker-compose up -d`. It will take about 2 minutes for all containers to start and for Confluent Control Center GUI to be ready. You can check when it's ready when the logs show the following event

```bash
$ docker-compose logs -f control-center | grep -e HTTP
control-center_1       | [2017-09-06 16:37:33,133] INFO Started NetworkTrafficServerConnector@26a529dc{HTTP/1.1}{0.0.0.0:9021} (org.eclipse.jetty.server.NetworkTrafficServerConnector)
```

3. Once everything is up and stable, open the Control Center GUI at [http://localhost:9021](http://localhost:9021). You can optionally rename the cluster with the following commands from your host machine:

```bash
# If you have `jq`
$ curl -X PATCH  -H "Content-Type: application/merge-patch+json" -d '{"displayName":"Kafka East"}' http://localhost:9021/2.0/clusters/kafka/$(curl -X get http://localhost:9021/2.0/clusters/kafka/ | jq --raw-output .[0].clusterId)

# If you don't have `jq`
$ curl -X PATCH  -H "Content-Type: application/merge-patch+json" -d '{"displayName":"Kafka East"}' http://localhost:9021/2.0/clusters/kafka/$(curl -X get http://localhost:9021/2.0/clusters/kafka/ | awk -v FS="(clusterId\":\"|\",\"displayName)" '{print $2}' )
```

4. Start streaming from IRC, source connector:

```bash
$ ./scripts/submit_wikipedia_irc_config.sh
```

5. Watch the live messages from the `wikipedia.parsed` topic:

```bash
$ ./scripts/listen_wikipedia.parsed.sh
```

6. Watch the SMT failed messages (poison pill routing) from the `wikipedia.failed` topic:

```bash
$ ./scripts/listen_wikipedia.failed.sh
```

7. Tell Elasticsearch what the data looks like:

```bash
$ ./scripts/set_elasticsearch_mapping.sh
```

8. Start sending data to Elasticsearch, sink connector:

```bash
$ ./scripts/submit_elastic_sink_config.sh
```

9. Open Kibana [http://localhost:5601/](http://localhost:5601/)

10. Check back in with Control Center GUI to see status on messages produced/consumed


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
