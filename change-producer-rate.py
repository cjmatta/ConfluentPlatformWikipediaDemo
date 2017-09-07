import re
import requests
import argparse
import utils

parser = argparse.ArgumentParser()
parser.add_argument('-p', '--producer', dest='producer', required=True, help='Name of the producer to change the rate for.')
parser.add_argument('-r', '--rate', dest='rate', type=int, required=True, help='The new rate to change the consumer to.')

args = parser.parse_args()

for container in utils.docker_client.containers():
    container_name = container['Names'][0]

    if container['State'] == 'running':
        match = re.search("producer_(.+)_\d+$", container_name)

        if match and match.group(1) == args.producer:
            public_port = utils.get_public_port(container, 8801)
            rest_uri = 'http://{}:{}/producer/rate?newRate={}'.format(utils.docker_hostname, public_port, args.rate)
            r = requests.put(rest_uri)
            print 'Rate changed for {} to {}'.format(container_name, r.text)