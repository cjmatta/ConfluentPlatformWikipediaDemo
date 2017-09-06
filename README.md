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

