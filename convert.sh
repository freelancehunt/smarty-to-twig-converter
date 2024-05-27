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

TEMPLATE_PATH="$1"

MOUNT_TO="/app/templates"
if [ -d "$TEMPLATE_PATH" ]; then
    MOUNT_FROM="$TEMPLATE_PATH"
    CONVERTABLE="$MOUNT_TO"
elif [ -f "$TEMPLATE_PATH" ]; then
    MOUNT_FROM=$(dirname "$TEMPLATE_PATH")
    CONVERTABLE="$MOUNT_TO/$(basename "$TEMPLATE_PATH")"
else
    echo "$TEMPLATE_PATH is invalid"
    exit 1
fi

docker run -u $(id -u):$(id -g) -e PHP_IDE_CONFIG="serverName=smarty2twig" -it --rm --name twigConverter \
-v $PWD:/app \
-v "$MOUNT_FROM":"$MOUNT_TO" \
fh_twig_converter php \
-d xdebug.client_host=$DOCKER_HOST \
-d xdebug.start_with_request=yes \
-d xdebug.mode=debug,develop \
-d xdebug.discover_client_host=true \
-d xdebug.start_with_request=yes \
-d xdebug.log_level=0 \
toTwig convert --path="$CONVERTABLE"
