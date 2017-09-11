#!/bin/bash

# Script to build the kafka-connect-irc connector and move them to the plugin path directory
DIR=$(cd $(dirname $0); pwd);

PLUGINPATH="$DIR/../connect-plugins"
if [ ! -d "$PLUGINPATH" ]; then
    mkdir $PLUGINPATH
fi

cd $DIR/../kafka-connect-irc && \
mvn clean package && \
cp -R ./target/kafka-connect-irc-3.3.0-package/share/java/kafka-connect-irc $DIR/../connect-plugins/kafka-connect-irc

# now build the transfomer

cd $DIR/../kafka-connect-transform-wikiedit && \
mvn clean package && \
cp -R target/WikiEditTransformation-3.3.0.jar $DIR/../connect-plugins
