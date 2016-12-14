FROM confluentinc/cp-kafka-connect:latest
LABEL org.cmatta.docker.demo=true

ADD ./connectors/kafka-connect-irc/target/kafka-connect-irc-1.0-SNAPSHOT-package/etc/kafka-connect-irc /etc/kafka-connect-irc
ADD ./connectors/kafka-connect-irc/target/kafka-connect-irc-1.0-SNAPSHOT-package/share/java/kafka-connect-irc /usr/share/java/kafka-connect-irc
