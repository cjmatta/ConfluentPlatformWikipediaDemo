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

2. Start Docker Compose. It will take about 2 minutes for all containers to start and for Confluent Control Center GUI to be ready. You can check when it's ready when the logs show the following event

```bash
$ docker-compose up -d
...
$ docker-compose logs -f control-center | grep -e HTTP
control-center_1       | [2017-09-06 16:37:33,133] INFO Started NetworkTrafficServerConnector@26a529dc{HTTP/1.1}{0.0.0.0:9021} (org.eclipse.jetty.server.NetworkTrafficServerConnector)
```

3. Once everything is up and stable, including Confluent Control Center, run the setup script that configures the Kafka connectors and partially configures Kibana:

```bash
$ ./scripts/setup.sh
```

4. Open Kibana [http://localhost:5601/](http://localhost:5601/). Navigate to "Management --> Saved Objects" and click `Import` and load the `kibana_dash.json` file, click "Yes, overwrite all". Navigate to the Dashboard tab (speedometer icon) and open "Wikipedia".

5. Open the Control Center GUI at [http://localhost:9021](http://localhost:9021) and see the Kafka connectors and status of messages produced and consumed


### Slow Consumers

To simulate a slow consumer, we will use Kafka's quota feature to rate-limit consumption from the broker side.

1. Start consuming from topic `wikipedia.parsed` with a new consumer group `app` which has two consumers `consumer_app_1` and `consumer_app_2`. It will run in the background.

```bash
$ ./scripts/start_consumer_app.sh
```

2. Let the above consumers run for a while until it has steady consumption.

3. Add a consumption quota for one of the consumers in the consumer group `app`

```bash
$ ./scripts/throttle_consumer.sh 1 add
```

4. View in C3 how this one consumer starts to lag.

5. Remove the consumption quota for the consumer.

```bash
$ ./scripts/throttle_consumer.sh 1 delete
```

6. Stop consuming from topic `wikipedia.parsed` with a new consumer group `app`.

```bash
$ ./scripts/stop_consumer_app.sh
```

### KSQL

1. KSQL Docker image doesn't have the `monitoring-interceptors-3.3.0.jar` yet. Until then,
use volumes to get in there. The Docker compose file assumes that you have this jar file
on your local host in `/tmp/monitoring-interceptors-3.3.0.jar`.

```bash
$ ls /tmp/monitoring-interceptors-3.3.0.jar
```

2. Copy the `ksqlproperties` file to `/tmp/ksqlproperties`. The Docker compose file assumes
 that you have this properties file on your local host in `/tmp/ksqlproperties`.

```bash
$ cp ksqlproperties /tmp/ksqlproperties
```

3. Start KSQL

```bash
$ docker-compose exec ksql-cli ksql-cli local --bootstrap-server kafka:9092 --properties-file /tmp/ksqlproperties
```

4. Create the raw source stream

```bash
ksql> CREATE STREAM wikipedia_source (schema string, payload string) WITH (kafka_topic='wikipedia.parsed', value_format='JSON');
```

5. Create a structured table

```bash
ksql> CREATE STREAM wikipedia AS SELECT \
  extractJsonField(payload, '$.wikipage') AS wikipage, \
  extractJsonField(payload, '$.username') AS username, \
  extractJsonField(payload, '$.commitmessage') AS commitmessage, \
  CAST(extractJsonField(payload, '$.bytechange') AS BIGINT) AS bytechange, \
  extractJsonField(payload, '$.diffurl') AS diffurl, \
  CAST(extractJsonField(payload, '$.createdat') AS BIGINT) AS createdat, \
  extractJsonField(payload, '$.channel') AS channel, \
  extractJsonField(payload, '$.isnew') AS isnew, \
  extractJsonField(payload, '$.isminor') AS isminor, \
  extractJsonField(payload, '$.isbot') AS isbot, \
  extractJsonField(payload, '$.isunpatrolled') AS isunpatrolled \
  from wikipedia_source where payload <> 'null';
```

6. Create a new stream of non-bot edits

```bash
ksql> CREATE STREAM wikipedianobot AS SELECT * FROM wikipedia WHERE isbot <> 'true';
```

### See Topic Messages

In a different terminal, watch the live messages from the `wikipedia.parsed` topic:

```bash
$ ./scripts/listen_wikipedia.parsed.sh
```

In a different terminal, watch the SMT failed messages (poison pill routing) from the `wikipedia.failed` topic:

```bash
$ ./scripts/listen_wikipedia.failed.sh
```


### Teardown and stopping
Stop and destroy all components and clear all volumes from Docker.

```bash
$ ./scripts/reset_demo.sh
```

