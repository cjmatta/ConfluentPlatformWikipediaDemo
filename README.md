### Confluent Platform Wikipedia Demo

This demo is a streaming pipeline using Apache Kafka. It connects to the Wikimedia Foundation's IRC channels (e.g. #en.wikipedia, #en.wiktionary) and streams the edits happening to Kafka via [kafka-connect-irc](https://github.com/cjmatta/kafka-connect-irc). The raw messages are transformed using a Kafka Connect Single Message Transform: [kafka-connect-transform-wikiedit](https://github.com/cjmatta/kafka-connect-transform-wikiedit) and the parsed messages are materialized into Elasticsearch for analysis by Kibana.

![image](drawing.png)

Components:
* [Confluent Control Center](http://docs.confluent.io/current/control-center/docs/index.html)
* [Kafka Connect](http://docs.confluent.io/current/connect/index.html)
* [Kafka Streams](http://docs.confluent.io/current/streams/index.html)
* [KSQL](https://github.com/confluentinc/ksql)
* [Confluent Schema Registry](http://docs.confluent.io/current/schema-registry/docs/index.html)
* [kafka-connect-irc source connector](https://github.com/cjmatta/kafka-connect-irc)
* [kafka-connect-elasticsearch sink connector](http://docs.confluent.io/current/connect/connect-elasticsearch/docs/elasticsearch_connector.html)
* [Elasticsearch](https://www.elastic.co/products/elasticsearch)
* [Kibana](https://www.elastic.co/products/kibana)

### Installation

1. Since this repository uses submodules, clone with `--recursive`:

```
$ git clone --recursive git@github.com:confluentinc/ConfluentPlatformWikipediaDemo.git
```

Otherwise, git clone and then submodule init/update:

```
$ git clone git@github.com:confluentinc/ConfluentPlatformWikipediaDemo.git
$ cd ConfluentPlatformWikipediaDemo
$ git submodule init
Submodule 'kafka-connect-irc' (https://github.com/cjmatta/kafka-connect-irc) registered for path 'kafka-connect-irc'
Submodule 'kafka-connect-transform-wikiedit' (https://github.com/cjmatta/kafka-connect-transform-wikiedit) registered for path 'kafka-connect-transform-wikiedit'
$ git submodule update
```

2. Increase the memory available to Docker. Default is 2GB, increase to at least 6GB.


### Running the Demo

1. Run `make clean all` to build the IRC connector and the transformer that will parse the Wikipedia edit messages to data. These are saved to `connect-plugins` path, which is a shared volume to the `connect` docker container

```bash
$ make clean all
...
$ ls connect-plugins
```

2. Start Docker Compose. It will take about 2 minutes for all containers to start and for Confluent Control Center GUI to be ready.

```bash
$ docker-compose up -d
```

3. Wait till Confluent Control Center is running fully.  You can check when it's ready when the logs show the following event

```bash
$ docker-compose logs -f control-center | grep -e HTTP
control-center_1       | [2017-09-06 16:37:33,133] INFO Started NetworkTrafficServerConnector@26a529dc{HTTP/1.1}{0.0.0.0:9021} (org.eclipse.jetty.server.NetworkTrafficServerConnector)
```

4. Now you must decide whether you want to run data straight through Kafka from Wikipedia IRC to Elasticsearch connectors without KSQL or with KSQL.
If you want to run traffic straight from Wikipedia IRC to Elasticsearch, then run this script to setup the connectors:

```bash
$ ./scripts_no_app/setup.sh
```

5. If you want to run traffic from Wikipedia IRC through KSQL to Elasticsearch, then follow these steps (only if you skipped the step above).

(a) Setup the connectors

```bash
$ ./scripts_ksql_app/sink_from_ksql/setup.sh
```

(b) Start KSQL

```bash
$ docker-compose exec ksql-cli ksql-cli local --bootstrap-server kafka:9092 --properties-file /tmp/ksqlproperties
```

(c) Run saved KSQL commands which generates an output topic that feeds into the Elasticsearch sink connector.

```bash
ksql> run script '/tmp/ksqlcommands';
```

(d) Leave KSQL application open for the duration of the demo to keep Kafka clients running. If you close KSQL, data processing will stop.

6. Open Kibana [http://localhost:5601/](http://localhost:5601/).

7. Navigate to "Management --> Saved Objects" and click `Import`. Then choose of these two options:

(a) If you are running traffic straight from Wikipedia IRC to Elasticsearch without KSQL, then load the `scripts_no_app/kibana_dash.json` file

(b) If you are running traffic from Wikipedia IRC through KSQL to Elasticsearch, then load the `scripts_ksql_app/kibana_dash.json` file

8. Click "Yes, overwrite all".

9. Navigate to the Dashboard tab (speedometer icon) and open your new dashboard.

10. Open the Control Center GUI at [http://localhost:9021](http://localhost:9021) and see the message delivery status, consumer groups, connectors.


### Slow Consumers

To simulate a slow consumer, we will use Kafka's quota feature to rate-limit consumption from the broker side.

1. Start consuming from topic `wikipedia.parsed` with a new consumer group `app` which has two consumers `consumer_app_1` and `consumer_app_2`. It will run in the background.

```bash
$ ./scripts_no_app/start_consumer_app.sh
```

2. Let the above consumers run for a while until it has steady consumption.

3. Add a consumption quota for one of the consumers in the consumer group `app`

```bash
$ ./scripts_no_app/throttle_consumer.sh 1 add
```

4. View in C3 how this one consumer starts to lag.

5. Remove the consumption quota for the consumer.

```bash
$ ./scripts_no_app/throttle_consumer.sh 1 delete
```

6. Stop consuming from topic `wikipedia.parsed` with a new consumer group `app`.

```bash
$ ./scripts_no_app/stop_consumer_app.sh
```

### See Topic Messages

In a different terminal, watch the live messages from the `wikipedia.parsed` topic:

```bash
$ ./scripts_no_app/listen_wikipedia.parsed.sh       # If not using KSQL (Avro with Schema Registry)
$ ./scripts_ksql_app/listen_wikipedia.parsed.sh     # If using KSQL (no Avro, just JSON)
```

In a different terminal, watch the SMT failed messages (poison pill routing) from the `wikipedia.failed` topic:

```bash
$ ./scripts_no_app/listen_wikipedia.failed.sh
```


### Teardown and stopping
Stop and destroy all components and clear all volumes from Docker.

```bash
$ ./scripts_no_app/reset_demo.sh
```

