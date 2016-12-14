clean: \
	clean-connecthost-dockerfile \
	clean-connectors \
	clean-containers

clean-containers:
	for container in `docker ps -aq -f label=org.cmatta.docker.demo=true` ; do \
        echo "\nRemoving container $${container} \n========================================== " ; \
                docker rm -f $${container} || exit 1 ; \
	done

clean-connecthost-dockerfile:
	if [ -f connecthost/Dockerfile ]; then \
		rm connecthost/Dockerfile; \
	fi

clean-connectors:
	rm -rf connecthost/connectors/*

create-connecthost:
	cd connecthost \
		&& bash create_connecthost.sh \
		&& docker build -t cmatta/wikipediaconnect:latest .
