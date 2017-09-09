#!/bin/bash

# Open Kibana http://localhost:5601
# Navigate to the management tab (gear icon) and click on "Index Patterns"
# Configure an index pattern: specify "wikipediabot" in the pattern box and ensure that "Time-field name" reads createdat
# Click "Create"
# Navigate to the "Advanced Settings" tab and set the following:
# timelion:es.timefield: createdat
# timelion:es.default_index: wikipediabot
# Navigate to the "Saved Objects" tab and click import and load the kibana_dash.json file.
# Navigate to the Dashboard tab (speedometer icon) and click open -> "Wikipedia"

curl -X PUT -H "kbn-version: 5.5.2" -d '{"title":"wikipediabot","notExpandable":true}' http://localhost:5601/es_admin/.kibana/index-pattern/wikipediabot/_create 
curl -X POST -H "kbn-version: 5.5.2" -H "Content-Type: application/json;charset=UTF-8" -d '{"value":"wikipediabot"}' http://localhost:5601/api/kibana/settings/timelion:es.default_index
curl -X POST -H "kbn-version: 5.5.2" -H "Content-Type: application/json;charset=UTF-8" -d '{"value":"CREATEDAT"}' http://localhost:5601/api/kibana/settings/timelion:es.timefield
