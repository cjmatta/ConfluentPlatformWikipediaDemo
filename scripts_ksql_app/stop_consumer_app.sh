#!/bin/bash

kill $(ps aux | grep confluentplatformwikipediademo_connect_1 | grep -v "grep confluentplatformwikipediademo_connect_1" | awk '{print $2}')
docker exec confluentplatformwikipediademo_connect_1 kill $(ps aux | grep consumer | grep -v "grep consumer" | awk '{print $2}')

