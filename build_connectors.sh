#!/bin/bash
# This script will checkout, build and include connectors
# for a Kafka Connect host
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )"
CONNECTOR_VOLUMES=""

git submodule update

pushd ${DIR}/connectors
for CONNECTOR in $(ls) ; do
  pushd ${CONNECTOR}
  mvn clean package
  if [[ $? -eq 0 ]];then
      printf "Successfully built ${CONNECTOR}"
      PACKAGE_NAME=$(find target -type d -name "*package");
      CONNECTOR_VOLUMES=$(printf "${CONNECTOR_VOLUMES}\n- ./connectors/%s/%s/etc/%s:/etc/%s" "${CONNECTOR}" "${PACKAGE_NAME}" "${CONNECTOR}" "${CONNECTOR}");
      CONNECTOR_VOLUMES=$(printf "${CONNECTOR_VOLUMES}\n- ./connectors/%s/%s/share/java/%s:/usr/share/java/%s" "${CONNECTOR}" "${PACKAGE_NAME}" "${CONNECTOR}" "${CONNECTOR}");
  else
      printf "Error: see above logs for details."
      exit 1
  fi
  popd
done
popd

printf "\nMake sure these volume entries are in the docker-compose.yml file in the connect section:\n"
printf "${CONNECTOR_VOLUMES}\n"
