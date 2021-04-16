#!/bin/bash

#### VARs ####
DOCKER="$(which docker)";
DISK_USAGE_ALERT=85;
DISK_USAGE_CURRENT=$(df -h / --output=pcent | tail -n1 | sed 's/ //g' | sed 's/%//');
##############

if [ $DISK_USAGE_CURRENT -ge $DISK_USAGE_ALERT 2> /dev/null ]; then
        $DOCKER system prune -af 1> /dev/null;
        $DOCKER volume prune -f 1> /dev/null;
else
        exit 0;
fi
