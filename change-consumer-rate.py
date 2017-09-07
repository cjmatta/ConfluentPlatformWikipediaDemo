import re
import requests
import argparse
import utils

parser = argparse.ArgumentParser()
parser.add_argument('-c', '--consumer', dest='consumer', required=True, help='Name of the consumer to change the rate for.')
parser.add_argument('-r', '--rate', dest='rate', type=int, required=True, help='The new rate to change the consumer to.')

args = parser.parse_args()

for container in utils.docker_client.containers():
    container_name = container['Names'][0]
    match = re.search("consumer_(.+)_\d+_\d+", container_name)

    if container['State'] == 'running':
        if match and match.group(1) == args.consumer:
            public_port = utils.get_public_port(container, 8800)
            rest_uri = 'http://{}:{}/consumer/rate?newRate={}'.format(utils.docker_hostname, public_port, args.rate)
            r = requests.put(rest_uri)
            print 'Rate changed for {} to {}'.format(container_name, r.text)
