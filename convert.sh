#!/bin/sh
# read https://docs.docker.com/network/bridge/

if [ -n "$(which ifconfig)" ]; then
    DOCKER_HOST=`ifconfig docker0 | awk '$1 == "inet" {print $2}'`
elif [ -n "$(which ip)" ]; then
    DOCKER_HOST=`ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+'`
else
    echo "\033[0;31mError: can't get docker host IP(neither \`ifconfig\` nor \`ip\` utility found)\033[0m"
	exit 1
fi


# without profiling
docker exec -i -e PHP_IDE_CONFIG="serverName=freelancehunt.local" php-cli php \
-d xdebug.client_host=$DOCKER_HOST \
-d xdebug.start_with_request=yes \
"$@"

# with profiling
# docker exec -i -e PHP_IDE_CONFIG="serverName=freelancehunt.local" php-cli php \
# -d xdebug.client_host=$DOCKER_HOST \
# -d xdebug.start_with_request=yes \
# -d xdebug.mode=profile \
# -d xdebug.output_dir='/application/profiling' \
# -d xdebug.profiler_append=1 \
# -d xdebug.profiler_output_name=cachegrind.%p.%u \
# "$@"
