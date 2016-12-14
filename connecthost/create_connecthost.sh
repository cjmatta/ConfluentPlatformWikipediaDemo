#!/bin/bash
# This script will checkout, build and include connectors
# for a Kafka Connect host
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"
CONNECTORS=(
    https://github.com/cjmatta/kafka-connect-irc
    )

CONNECTOR_DOCKER_VOLUMES=""

pushd ${DIR}/connectors
for CONNECTOR in ${CONNECTORS[@]} ; do
	CONNECTOR_NAME=$(echo ${CONNECTOR} | awk -F\\/ '{print $5}');
    if [[ ! -d ${CONNECTOR_NAME} ]]; then
        git clone ${CONNECTOR};
    fi
    pushd ${CONNECTOR_NAME}
    mvn clean package; \
    if [[ $? -eq 0 ]];then
        PACKAGE_NAME=$(find target -type d -name "*package");
        CONNECTOR_VOLUMES+=$(printf "\nADD ./connectors/%s/%s/etc/%s /etc/%s" "${CONNECTOR_NAME}" "${PACKAGE_NAME}" "${CONNECTOR_NAME}" "${CONNECTOR_NAME}");
        CONNECTOR_VOLUMES+=$(printf "\nADD ./connectors/%s/%s/share/java/%s /usr/share/java/%s" "${CONNECTOR_NAME}" "${PACKAGE_NAME}" "${CONNECTOR_NAME}" "${CONNECTOR_NAME}");
    else
        printf "Error: see above logs for details."
    fi
    popd
done
popd

cat << EOF > ${DIR}/Dockerfile
FROM confluentinc/cp-kafka-connect:latest
LABEL org.cmatta.docker.demo=true
${CONNECTOR_VOLUMES}
EOF

docker build -t cmatta/wikiconnecthost:latest .
