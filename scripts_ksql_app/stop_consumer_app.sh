#!/bin/bash

kill $(ps aux | grep confluentplatformwikipediademo_connect_1 | grep -v "grep confluentplatformwikipediademo_connect_1" | awk '{print $2}')

