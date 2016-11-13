#!/bin/bash

# all parameters to this shell script are optional, defaults will be used otherwise
USERGRID_HOST=$1
ORG_NAME=$2
APP_NAME=$3
ADMIN_PASS=$4

dprint() {
    echo "`date` ---> ${@}" 2>&1
}

dprint "stop running docker containers"
docker stop $(docker ps --quiet)

dprint "remove existing container images"
docker rm -f usergrid cassandra elasticsearch portal

dprint "start containers"
docker run -d --log-driver=syslog --name cassandra -p 9160:9160 -p 9042:9042 --volume ./cassandra-data:/var/lib/cassandra neoreeps/ug-cassandra
docker run -d --log-driver=syslog --name elasticsearch --volume ./elasticsearch-data:/data neoreeps/ug-elasticsearch
docker run -d --log-driver=syslog --name usergrid --env ADMIN_PASS=${ADMIN_PASS} --env ORG_NAME=${ORG_NAME} --env APP_NAME=${APP_NAME} --link elasticsearch:elasticsearch --link cassandra:cassandra -p 8080:8080 -t neoreeps/usergrid
docker run -d --log-driver=syslog --name portal --env USERGRID_HOST=${USERGRID_HOST} -p 80:80 neoreeps/ug-portal
